import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/env.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/providers/binaries/bitcoin_core_pid_tracker.dart';
import 'package:sail_ui/providers/binaries/download_manager.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:synchronized/synchronized.dart';

/// Manages downloads, installations and running of binaries
class BinaryProvider extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;

  final settings = GetIt.I.get<SettingsProvider>();

  MainchainRPC? _mainchainRPC;
  EnforcerRPC? _enforcerRPC;

  MainchainRPC? get mainchainRPC {
    if (_mainchainRPC == null && GetIt.I.isRegistered<MainchainRPC>()) {
      _mainchainRPC = GetIt.I.get<MainchainRPC>();
      _mainchainRPC!.addListener(notifyListeners);
    }
    return _mainchainRPC;
  }

  EnforcerRPC? get enforcerRPC {
    if (_enforcerRPC == null && GetIt.I.isRegistered<EnforcerRPC>()) {
      _enforcerRPC = GetIt.I.get<EnforcerRPC>();
      _enforcerRPC!.addListener(notifyListeners);
    }
    return _enforcerRPC;
  }

  BitwindowRPC? _bitwindowRPC;
  ThunderRPC? _thunderRPC;
  BitnamesRPC? _bitnamesRPC;
  BitAssetsRPC? _bitassetsRPC;
  ZSideRPC? _zsideRPC;

  BitwindowRPC? get bitwindowRPC {
    if (_bitwindowRPC == null && GetIt.I.isRegistered<BitwindowRPC>()) {
      _bitwindowRPC = GetIt.I.get<BitwindowRPC>();
      _bitwindowRPC!.addListener(notifyListeners);
    }
    return _bitwindowRPC;
  }

  ThunderRPC? get thunderRPC {
    if (_thunderRPC == null && GetIt.I.isRegistered<ThunderRPC>()) {
      _thunderRPC = GetIt.I.get<ThunderRPC>();
      _thunderRPC!.addListener(notifyListeners);
    }
    return _thunderRPC;
  }

  BitnamesRPC? get bitnamesRPC {
    if (_bitnamesRPC == null && GetIt.I.isRegistered<BitnamesRPC>()) {
      _bitnamesRPC = GetIt.I.get<BitnamesRPC>();
      _bitnamesRPC!.addListener(notifyListeners);
    }
    return _bitnamesRPC;
  }

  BitAssetsRPC? get bitassetsRPC {
    if (_bitassetsRPC == null && GetIt.I.isRegistered<BitAssetsRPC>()) {
      _bitassetsRPC = GetIt.I.get<BitAssetsRPC>();
      _bitassetsRPC!.addListener(notifyListeners);
    }
    return _bitassetsRPC;
  }

  ZSideRPC? get zsideRPC {
    if (_zsideRPC == null && GetIt.I.isRegistered<ZSideRPC>()) {
      _zsideRPC = GetIt.I.get<ZSideRPC>();
      _zsideRPC!.addListener(notifyListeners);
    }
    return _zsideRPC;
  }

  late final DownloadManager _downloadManager;
  late final ProcessManager _processManager;

  StreamSubscription<FileSystemEvent>? _dirWatcher;
  Timer? _releaseCheckTimer;

  // Per-binary locks to ensure sequential processing
  final Map<BinaryType, Lock> _updateLocks = {};

  // BitcoinCore has it's very own bitcoin.pid we can track to check aliveness!
  final BitcoinCorePidTracker _bitcoinCorePidTracker = BitcoinCorePidTracker();

  // Connection status getters
  bool get mainchainConnected => mainchainRPC?.connected ?? false;
  bool get enforcerConnected => enforcerRPC?.connected ?? false;
  bool get bitwindowConnected => bitwindowRPC?.connected ?? false;
  bool get thunderConnected => thunderRPC?.connected ?? false;
  bool get bitnamesConnected => bitnamesRPC?.connected ?? false;
  bool get bitassetsConnected => bitassetsRPC?.connected ?? false;
  bool get zsideConnected => zsideRPC?.connected ?? false;

  bool get mainchainInitializing => mainchainRPC?.initializingBinary ?? false;
  bool get enforcerInitializing => enforcerRPC?.initializingBinary ?? false;
  bool get bitwindowInitializing => bitwindowRPC?.initializingBinary ?? false;
  bool get thunderInitializing => thunderRPC?.initializingBinary ?? false;
  bool get bitnamesInitializing => bitnamesRPC?.initializingBinary ?? false;
  bool get bitassetsInitializing => bitassetsRPC?.initializingBinary ?? false;
  bool get zsideInitializing => zsideRPC?.initializingBinary ?? false;

  bool get mainchainStopping => mainchainRPC?.stoppingBinary ?? false;
  bool get enforcerStopping => enforcerRPC?.stoppingBinary ?? false;
  bool get bitwindowStopping => bitwindowRPC?.stoppingBinary ?? false;
  bool get thunderStopping => thunderRPC?.stoppingBinary ?? false;
  bool get bitnamesStopping => bitnamesRPC?.stoppingBinary ?? false;
  bool get bitassetsStopping => bitassetsRPC?.stoppingBinary ?? false;
  bool get zsideStopping => zsideRPC?.stoppingBinary ?? false;

  DownloadInfo get mainchainDownloadState => _downloadManager.getProgress(BinaryType.bitcoinCore);
  DownloadInfo get enforcerDownloadState => _downloadManager.getProgress(BinaryType.enforcer);
  DownloadInfo get bitwindowDownloadState => _downloadManager.getProgress(BinaryType.bitWindow);
  DownloadInfo get thunderDownloadState => _downloadManager.getProgress(BinaryType.thunder);
  DownloadInfo get bitnamesDownloadState => _downloadManager.getProgress(BinaryType.bitnames);
  DownloadInfo get bitassetsDownloadState => _downloadManager.getProgress(BinaryType.bitassets);
  DownloadInfo get zsideDownloadState => _downloadManager.getProgress(BinaryType.zSide);

  // Only show errors for explicitly launched binaries
  String? get mainchainError => mainchainRPC?.connectionError;
  String? get enforcerError => enforcerRPC?.connectionError;
  String? get bitwindowError => bitwindowRPC?.connectionError;
  String? get thunderError => thunderRPC?.connectionError;
  String? get bitnamesError => bitnamesRPC?.connectionError;
  String? get bitassetsError => bitassetsRPC?.connectionError;
  String? get zsideError => zsideRPC?.connectionError;

  // Only show errors for explicitly launched binaries
  String? get mainchainStartupError => mainchainRPC?.startupError;
  String? get enforcerStartupError => enforcerRPC?.startupError;
  String? get bitwindowStartupError => bitwindowRPC?.startupError;
  String? get thunderStartupError => thunderRPC?.startupError;
  String? get bitnamesStartupError => bitnamesRPC?.startupError;
  String? get bitassetsStartupError => bitassetsRPC?.startupError;
  String? get zsideStartupError => zsideRPC?.startupError;

  // let the download manager handle all binary stuff. Only it does updates!
  List<Binary> get binaries => _downloadManager.binaries;
  ExitTuple? exited(Binary binary) => _processManager.exited(binary);
  Stream<String>? stderr(Binary binary) => _processManager.stderr(binary);

  // Track starter usage for L2 chains
  final Map<String, bool> _useStarter = {};
  void setUseStarter(Binary binary, bool value) {
    _useStarter[binary.name] = value;
    notifyListeners();
  }

  // Private constructor
  BinaryProvider._create({
    required this.appDir,
    required DownloadManager downloadManager,
    required ProcessManager processManager,
  }) : _downloadManager = downloadManager,
       _processManager = processManager {
    // RPC clients will be lazily initialized when first accessed

    // Forward process manager notifications to BinaryProvider listeners
    _processManager.addListener(notifyListeners);

    // Forward download manager notifications to BinaryProvider listeners
    _downloadManager.addListener(notifyListeners);

    // Optional RPCs will be lazily initialized when first accessed

    _init();
  }

  // Test constructor (visible for mocking)
  @visibleForTesting
  BinaryProvider.test({
    required this.appDir,
    required DownloadManager downloadManager,
    required ProcessManager processManager,
  }) : _downloadManager = downloadManager,
       _processManager = processManager {
    // Skip GetIt registration for tests
  }

  // Async factory
  static Future<BinaryProvider> create({
    required Directory appDir,
    required List<Binary> initialBinaries,
  }) async {
    final downloadManager = await DownloadManager.create(
      appDir: appDir,
      initialBinaries: initialBinaries,
    );

    final processManager = ProcessManager(appDir: appDir);

    final provider = BinaryProvider._create(
      appDir: appDir,
      downloadManager: downloadManager,
      processManager: processManager,
    );

    return provider;
  }

  Future<void> _init() async {
    if (Environment.isInTest) {
      return;
    }

    // Set up periodic release date checks
    _releaseCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkReleaseDates());

    _bitcoinCorePidTracker.startWatching();

    try {
      _setupDirectoryWatcher();
    } catch (e) {
      log.e('could not set up directory watcher: $e');
    }
  }

  // Start a binary, and set starter seeds (if set)
  Future<void> start(Binary binary) async {
    await _downloadManager.downloadIfMissing(binary);

    final SettingsProvider settings = GetIt.I.get<SettingsProvider>();
    if (binary.chainLayer == 2 && !settings.useTestSidechains) {
      binary = binary as Sidechain;
      log.i('booting sidechain ${binary.name}');
      // We're booting some sort of sidechain. Check the wallet-starter-directory for
      // a starter seed, but always bitwindow!
      final bitwindowAppDir = Directory(path.join(appDir.parent.path, 'bitwindow'));
      final mnemonicPath = binary.getMnemonicPath(bitwindowAppDir);
      log.i('mnemonic path: $mnemonicPath');
      if (mnemonicPath != null) {
        log.i('adding boot arg: --mnemonic-seed-phrase-path=$mnemonicPath');
        binary.addBootArg('--mnemonic-seed-phrase-path=$mnemonicPath');
        _downloadManager.updateBinary(
          binary.type,
          (currentBinary) => binary,
        );
      }
    }

    var rpcConnection = switch (binary) {
      var b when b is BitcoinCore => mainchainRPC,
      var b when b is Enforcer => enforcerRPC,
      var b when b is BitWindow => bitwindowRPC,
      var b when b is Thunder => thunderRPC,
      var b when b is BitNames => bitnamesRPC,
      var b when b is BitAssets => bitassetsRPC,
      var b when b is ZSide => zsideRPC,
      _ => null,
    };

    if (rpcConnection == null) {
      throw Exception('no RPC connection found for ${binary.name}');
    }

    await rpcConnection.initBinary((binary, args, cleanup, environment) async {
      return await _startProcess(binary, args, cleanup, environment: environment);
    });
  }

  // startProcess attempts to boot the binary passed, and waits until
  // it is successfully booted and connected. If it can't connect,
  // it returns an error message explaining why.
  Future<String?> _startProcess(
    Binary binary,
    List<String> args,
    Future<void> Function() cleanup, {
    // Environment variables passed to the process, e.g RUST_BACKTRACE: 1
    Map<String, String> environment = const {},
  }) async {
    String? error;

    try {
      await _processManager.start(binary, args, cleanup, environment: environment);

      final timeout = const Duration(seconds: 30);
      try {
        await Future.any([
          // Happy case: able to connect. we start a poller at the
          // beginning of this function that sets the connected variable
          // we return here
          waitForBoolToBeTrue(() async {
            return isConnected(binary);
          }),

          // A sad case: Binary is running, but not working for some reason
          waitForBoolToBeTrue(() async {
            return isInitializing(binary) && connectionError(binary) != null;
          }),

          // Not so happy case: process exited
          // Throw an error, which causes the error message to be shown
          // in the daemon status chip
          waitForBoolToBeTrue(() async {
            final res = exited(binary);
            if (res != null && res.message != '') {
              log.i('process exited with message: ${res.message}');
              error = res.message;
            }
            return res != null;
          }),

          Future.delayed(timeout).then((_) => throw "'$binary' connection timed out after ${timeout.inSeconds}s"),
          // Timeout case!
        ]);

        log.i('init binaries: $binary connected');
      } catch (err) {
        log.e('init binaries: could not connect to $binary', error: err);

        // Check one last time we're not running. If not, dig deep in logs to find a nice
        // error to return

        // We've quit! Assuming there's error logs, somewhere.
        if (!isRunning(binary) && connectionError(binary) == null) {
          final logs = await stderr(binary)?.toList();
          log.e('$binary exited before we could connect, dumping logs');
          for (var line in logs ?? []) {
            log.e('$binary: $line');
          }

          var lastLine = _stripFromString(logs?.last ?? '', ': ');
          error = lastLine;
        } else {
          error ??= err.toString();
        }
      }

      return error;
    } catch (err) {
      log.e('init binaries: could not start ${binary.connectionString}', error: err);
      return 'could not boot binary: ${binary.connectionString}: $err';
    } finally {
      notifyListeners();
    }
  }

  // Stops the binary you pass. First gracefully,
  // then forcefully.
  Future<void> stop(Binary binary) async {
    // Step 1: Call RPC stop()
    try {
      switch (binary) {
        case BitcoinCore():
          await mainchainRPC?.stop();
        case Enforcer():
          await enforcerRPC?.stop();
        case BitWindow():
          await bitwindowRPC?.stop();
        case Thunder():
          await thunderRPC?.stop();
        case BitNames():
          await bitnamesRPC?.stop();
        case BitAssets():
          await bitassetsRPC?.stop();
        case ZSide():
          await zsideRPC?.stop();
      }
    } catch (e) {
      log.e('could not stop ${binary.name}: $e');
    }

    // Step 2: Determine the PID to wait for and timeout duration
    int? pidToWaitFor;
    Duration timeout;

    if (binary.type == BinaryType.bitcoinCore) {
      // For Bitcoin Core, use the PID from our very special tracker
      // and use a 30s timeout because there can be a lot to clean up
      // on mainnet
      pidToWaitFor = _bitcoinCorePidTracker.currentPid;
      timeout = const Duration(seconds: 30);
      log.i('Waiting for Bitcoin Core PID ${pidToWaitFor ?? "unknown"} to exit (30s timeout)');
    } else {
      // For other binaries, use the PID from process manager with 10s timeout
      // If the binary wasnt booted by sailui, there will be no PID, and we
      // wont wait
      final process = _processManager.runningProcesses[binary.name];
      pidToWaitFor = process?.pid;
      timeout = const Duration(seconds: 10);
      log.i('Waiting for ${binary.name} PID ${pidToWaitFor ?? "unknown"} to exit (10s timeout)');
    }

    // Step 3: If we have a PID, wait for it to die
    if (pidToWaitFor != null) {
      final died = await _processManager.waitForPidDeath(pidToWaitFor, timeout);

      if (died) {
        log.i('${binary.name} shut down gracefully');
        return;
      }

      // Still alive after timeout, force kill it
      log.w('${binary.name} PID $pidToWaitFor still alive after ${timeout.inSeconds}s, force killing');
      await _processManager.killPid(pidToWaitFor);
      return;
    }

    // Step 4: No PID available, check if process already exited
    if (exited(binary) != null) {
      log.i('${binary.name} already exited');
      return;
    }

    // Final Step: Use process manager's kill method
    log.w('No PID found for ${binary.name}, killing with process manager');
    await _processManager.kill(binary);
  }

  /// Download a binary using the DownloadProvider
  Future<void> download(Binary binary, {bool shouldUpdate = false}) async {
    await _downloadManager.downloadIfMissing(binary, shouldUpdate: shouldUpdate);
  }

  /// Get download progress for a binary
  DownloadInfo downloadProgress(BinaryType type) {
    return _downloadManager.getProgress(type);
  }

  /// Update a binary using a transformer function
  void updateBinary(BinaryType type, Binary Function(Binary) updater) {
    _downloadManager.updateBinary(type, updater);
  }

  List<Binary> get runningBinaries => _processManager.runningProcesses.values.map((process) => process.binary).toList();

  // Returns true if the app currently has a succesful connection to the binary
  bool isConnected(Binary binary) {
    return switch (binary) {
      var b when b is BitcoinCore => mainchainConnected,
      var b when b is Enforcer => enforcerConnected,
      var b when b is BitWindow => bitwindowConnected,
      var b when b is Thunder => thunderConnected,
      var b when b is BitNames => bitnamesConnected,
      var b when b is BitAssets => bitassetsConnected,
      var b when b is ZSide => zsideConnected,
      _ => false,
    };
  }

  // Returns true if the app is currently trying to initialize the binary
  // but has not yet connected
  bool isInitializing(Binary binary) {
    return switch (binary) {
      var b when b is BitcoinCore => mainchainInitializing,
      var b when b is Enforcer => enforcerInitializing,
      var b when b is BitWindow => bitwindowInitializing,
      var b when b is Thunder => thunderInitializing,
      var b when b is BitNames => bitnamesInitializing,
      var b when b is BitAssets => bitassetsInitializing,
      var b when b is ZSide => zsideInitializing,
      _ => false,
    };
  }

  // Returns true if the binary has encountered a connection error
  // but has not yet connected
  String? connectionError(Binary binary) {
    return switch (binary) {
      var b when b is BitcoinCore => mainchainError,
      var b when b is Enforcer => enforcerError,
      var b when b is BitWindow => bitwindowError,
      var b when b is Thunder => thunderError,
      var b when b is BitNames => bitnamesError,
      var b when b is BitAssets => bitassetsError,
      var b when b is ZSide => zsideError,
      _ => null,
    };
  }

  // Return true if the binary is currently running
  bool isRunning(Binary binary) {
    return switch (binary) {
      var b when b is BitcoinCore => _processManager.isRunning(BitcoinCore()),
      var b when b is Enforcer => _processManager.isRunning(Enforcer()),
      var b when b is BitWindow => _processManager.isRunning(BitWindow()),
      var b when b is Thunder => _processManager.isRunning(Thunder()),
      var b when b is BitNames => _processManager.isRunning(BitNames()),
      var b when b is BitAssets => _processManager.isRunning(BitAssets()),
      var b when b is ZSide => _processManager.isRunning(ZSide()),
      _ => false,
    };
  }

  bool isStopping(Binary binary) {
    return switch (binary) {
      var b when b is BitcoinCore => mainchainStopping,
      var b when b is Enforcer => enforcerStopping,
      var b when b is BitWindow => bitwindowStopping,
      var b when b is Thunder => thunderStopping,
      var b when b is BitNames => bitnamesStopping,
      var b when b is BitAssets => bitassetsStopping,
      var b when b is ZSide => zsideStopping,
      _ => false,
    };
  }

  Future<void> startWithEnforcer(Binary binaryToBoot, {bool bootExtraBinaryImmediately = false}) async {
    final log = GetIt.I.get<Logger>();
    final startTime = DateTime.now();
    int getElapsed() => DateTime.now().difference(startTime).inMilliseconds;

    log.i('[T+0ms] STARTUP: Booting L1 binaries + ${binaryToBoot.name}');

    log.i('[T+${getElapsed()}ms] STARTUP: Ensuring all binaries are downloaded');

    // Ensure we have all required binaries
    final bitcoinCore = binaries.whereType<BitcoinCore>().first;
    final enforcer = binaries.whereType<Enforcer>().first;

    if (bootExtraBinaryImmediately) {
      log.i('[T+${getElapsed()}ms] STARTUP: Starting ${binaryToBoot.name}');
      unawaited(start(binaryToBoot));
    }

    await start(bitcoinCore);
    log.i('[T+${getElapsed()}ms] STARTUP: Started bitcoin core...');

    // if in launcher mode, we must await in a loop here UNTIL
    // the wallet has a starter! This is because we need to pass
    // the l1 mnemonic to the enforcer, to avoid it from generating
    // one itself
    while (true) {
      final bitwindowAppDir = Directory(path.join(appDir.parent.path, 'bitwindow'));
      final walletDir = getWalletDir(bitwindowAppDir);
      log.i(
        '[T+${getElapsed()}ms] STARTUP: Waiting for l1 starter..., walletDir: $walletDir, bitwindowAppDir: $bitwindowAppDir appDir: $appDir',
      );
      if (walletDir != null) {
        final mnemonicFile = File(path.join(walletDir.path, 'l1_starter.txt'));
        if (await mnemonicFile.exists()) {
          break;
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    await start(enforcer);
    log.i('[T+${getElapsed()}ms] STARTUP: Started enforcer');

    if (!bootExtraBinaryImmediately) {
      await start(binaryToBoot);
      log.i('[T+${getElapsed()}ms] STARTUP: Started ${binaryToBoot.name}');
    }

    log.i('[T+${getElapsed()}ms] STARTUP: All binaries started successfully');
  }

  Future<bool> onShutdown({ShutdownOptions? shutdownOptions}) async {
    try {
      // Get list of running binaries
      final runningBinaries = _processManager.runningProcesses.values.map((process) => process.binary).toList();

      final showShutdownPage = shutdownOptions != null && shutdownOptions.showShutdownPage;
      if (showShutdownPage) {
        // don't show the shutting down page if it's already shown!
        if (shutdownOptions.router.current.name != ShutDownRoute.name) {
          // Show shutdown page with running binaries
          unawaited(
            shutdownOptions.router.push(
              ShutDownRoute(
                binaries: runningBinaries,
                onComplete: shutdownOptions.onComplete,
              ),
            ),
          );
        }
      }

      final futures = <Future>[];
      // Only stop binaries that are started by bitwindow
      for (final process in _processManager.runningProcesses.values) {
        futures.add(stop(process.binary));
      }

      // Wait for all stop operations to complete
      await Future.wait(futures);

      if (!showShutdownPage) {
        // the shutdown doesnt call it, then we must!
        shutdownOptions?.onComplete();
      }
    } catch (error) {
      // do nothing, we just always need to return true
      log.e('error shutting down: $error');
    }

    return true;
  }

  void listenDownloadManager(VoidCallback listener) {
    _downloadManager.addListener(listener);
  }

  void removeDownloadManagerListener(VoidCallback listener) {
    _downloadManager.removeListener(listener);
  }

  void _setupDirectoryWatcher() {
    final allBinaries = [BitcoinCore(), Enforcer(), BitWindow(), Thunder(), BitNames(), BitAssets(), ZSide()];

    // Watch the assets directory for changes
    _dirWatcher = binDir(appDir.path).watch(recursive: true).listen((event) {
      // Find which binary changed
      final changedBinary = allBinaries.firstWhereOrNull((binary) => event.path.endsWith(binary.binary));

      // The event is not related to a binary, ignore it
      if (changedBinary == null) {
        return;
      }

      log.d('File system event for ${changedBinary.name}: ${event.type}');

      // Get or create lock for this binary
      final lock = _updateLocks.putIfAbsent(changedBinary.type, () => Lock());

      // Use synchronized to ensure only one update runs at a time. This also ensures
      // rapid updates always ends with the latest metadata.
      lock.synchronized(() async {
        try {
          log.d('Processing metadata update for ${changedBinary.name}');

          // Only reload metadata for the binary that changed
          final updatedBinary = await changedBinary.updateMetadata(appDir);

          _downloadManager.updateBinary(
            updatedBinary.type,
            (currentBinary) => currentBinary.copyWith(metadata: updatedBinary.metadata),
          );

          log.d('Successfully updated metadata for ${changedBinary.name}');
        } catch (e) {
          log.e('Failed to update metadata for ${changedBinary.name}', error: e);
        }
      });
    });
  }

  Future<void> _checkReleaseDates() async {
    for (var i = 0; i < binaries.length; i++) {
      try {
        final binary = binaries[i];
        final updatedBinary = await binary.updateMetadata(appDir);

        // Only update and mark as changed if the binary actually differs
        if (updatedBinary.metadata != binary.metadata) {
          _downloadManager.updateBinary(
            binary.type,
            (currentBinary) => currentBinary.copyWith(metadata: updatedBinary.metadata),
          );
        }
      } catch (e) {
        log.e('Error checking release date: $e');
      }
    }
  }

  @override
  void dispose() {
    _releaseCheckTimer?.cancel();
    _bitcoinCorePidTracker.dispose();
    _dirWatcher?.cancel();
    _downloadManager.removeListener(notifyListeners);
    mainchainRPC?.removeListener(notifyListeners);
    enforcerRPC?.removeListener(notifyListeners);
    bitwindowRPC?.removeListener(notifyListeners);
    thunderRPC?.removeListener(notifyListeners);
    bitnamesRPC?.removeListener(notifyListeners);
    bitassetsRPC?.removeListener(notifyListeners);
    zsideRPC?.removeListener(notifyListeners);
    _downloadManager.dispose();
    super.dispose();
  }
}

class ShutdownOptions {
  final RootStackRouter router;
  final VoidCallback onComplete;
  final bool showShutdownPage;

  const ShutdownOptions({
    required this.router,
    required this.onComplete,
    required this.showShutdownPage,
  });
}

Future<void> waitForBoolToBeTrue(
  Future<bool> Function() boolGetter, {
  Duration pollInterval = const Duration(milliseconds: 100),
}) async {
  bool result = await boolGetter();
  if (!result) {
    await Future.delayed(pollInterval);
    await waitForBoolToBeTrue(boolGetter, pollInterval: pollInterval);
  }
}

String _stripFromString(String input, String whatToStrip) {
  int startIndex = 0, endIndex = input.length;

  for (int i = 0; i <= input.length; i++) {
    if (i == input.length) {
      return '';
    }
    if (!whatToStrip.contains(input[i])) {
      startIndex = i;
      break;
    }
  }

  for (int i = input.length - 1; i >= 0; i--) {
    if (!whatToStrip.contains(input[i])) {
      endIndex = i;
      break;
    }
  }

  return input.substring(startIndex, endIndex + 1);
}

Future<List<Binary>> loadBinaryCreationTimestamp(List<Binary> binaries, Directory appDir) async {
  // Update metadata for all binaries in parallel
  return await Future.wait(binaries.map((binary) => binary.updateMetadata(appDir)));
}

Directory binDir(String appDir) => Directory(path.join(appDir, 'assets', 'bin'));
