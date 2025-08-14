import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/env.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/providers/binaries/download_manager.dart';
import 'package:sail_ui/sail_ui.dart';

/// Manages downloads, installations and running of binaries
class BinaryProvider extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;
  late final Directory bitwindowAppDir;

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
  })  : _downloadManager = downloadManager,
        _processManager = processManager {
    bitwindowAppDir = Directory(
      path.join(
        appDir.path,
        '..',
        'bitwindow',
      ),
    );

    // RPC clients will be lazily initialized when first accessed

    // Forward DownloadManager notifications to BinaryProvider listeners
    _processManager.addListener(notifyListeners);

    // Optional RPCs will be lazily initialized when first accessed

    _init();
  }

  // Test constructor (visible for mocking)
  @visibleForTesting
  BinaryProvider.test({
    required this.appDir,
    required DownloadManager downloadManager,
    required ProcessManager processManager,
  })  : _downloadManager = downloadManager,
        _processManager = processManager {
    // Skip GetIt registration for tests
    bitwindowAppDir = Directory('/tmp');
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

    final processManager = ProcessManager(
      appDir: appDir,
    );

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
    _releaseCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkReleaseDates(),
    );

    try {
      _setupDirectoryWatcher();
    } catch (e) {
      log.e('could not set up directory watcher: $e');
    }
  }

  // Start a binary, and set starter seeds (if set)
  Future<void> start(Binary binary) async {
    await _downloadManager.downloadIfMissing(binary);

    if (binary is Thunder || binary is Bitnames || binary is BitAssets) {
      binary = binary as Sidechain;
      log.i('booting sidechain ${binary.name}');
      // We're booting some sort of sidechain. Check the wallet-starter-directory for
      // a starter seed
      final mnemonicPath = binary.getMnemonicPath(bitwindowAppDir);
      log.i('mnemonic path: $mnemonicPath');
      if (mnemonicPath != null) {
        log.i('adding boot arg: --mnemonic-seed-phrase-path=$mnemonicPath');
        binary.addBootArg('--mnemonic-seed-phrase-path=$mnemonicPath');
      }
    }

    var rpcConnection = switch (binary) {
      var b when b is BitcoinCore => mainchainRPC,
      var b when b is Enforcer => enforcerRPC,
      var b when b is BitWindow => bitwindowRPC,
      var b when b is Thunder => thunderRPC,
      var b when b is Bitnames => bitnamesRPC,
      var b when b is BitAssets => bitassetsRPC,
      var b when b is ZSide => zsideRPC,
      _ => null,
    };

    if (rpcConnection == null) {
      throw Exception('no RPC connection found for ${binary.name}');
    }

    await rpcConnection.initBinary(
      (binary, args, cleanup, environment) async {
        return await _startProcess(binary, args, cleanup, environment: environment);
      },
    );
  }

  // startProcess attempts to boot the binary passed, and waits until
  // it is successfully booted and connected. If it can't connect,
  // it returns an error message explaining why.
  Future<String?> _startProcess(
    Binary binary,
    List<String> args,
    Future<void> Function() cleanup,
    // Environment variables passed to the process, e.g RUST_BACKTRACE: 1
    {
    Map<String, String> environment = const {},
  }) async {
    String? error;

    try {
      await _processManager.start(binary, args, cleanup, environment: environment);

      var timeout = const Duration(seconds: 60);
      if (binary.binary == 'zsided') {
        // zside can take a long time. initial sync as well
        timeout = const Duration(seconds: 5 * 60);
      }

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

          Future.delayed(timeout).then(
            (_) => throw "'$binary' connection timed out after ${timeout.inSeconds}s",
          ),
          // Timeout case!
        ]);

        log.i('init binaries: $binary connected');
      } catch (err) {
        log.e('init binaries: timed out connecting to $binary', error: err);

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
        case Bitnames():
          await bitnamesRPC?.stop();
        case BitAssets():
          await bitassetsRPC?.stop();
        case ZSide():
          await zsideRPC?.stop();
      }
    } catch (e) {
      log.e('could not stop ${binary.name}: $e');
    }

    // If the process exited, don't bother killing it
    if (exited(binary) != null) {
      return;
    }

    log.w('Killing process, graceful shutdown failed');
    await _processManager.kill(binary);
  }

  Future<void> stopAll() async {
    await _processManager.stopAll();
  }

  /// Download a binary using the DownloadProvider
  Future<void> download(Binary binary, {bool shouldUpdate = false}) async {
    await _downloadManager.downloadIfMissing(binary, shouldUpdate: shouldUpdate);
  }

  /// Get download progress for a binary
  DownloadInfo downloadProgress(Binary binary) => _downloadManager.getProgress(binary.name);

  List<Binary> get runningBinaries => _processManager.runningProcesses.values.map((process) => process.binary).toList();

  // Returns true if the app currently has a succesful connection to the binary
  bool isConnected(Binary binary) {
    return switch (binary) {
      var b when b is BitcoinCore => mainchainConnected,
      var b when b is Enforcer => enforcerConnected,
      var b when b is BitWindow => bitwindowConnected,
      var b when b is Thunder => thunderConnected,
      var b when b is Bitnames => bitnamesConnected,
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
      var b when b is Bitnames => bitnamesInitializing,
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
      var b when b is Bitnames => bitnamesError,
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
      var b when b is Bitnames => _processManager.isRunning(Bitnames()),
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
      var b when b is Bitnames => bitnamesStopping,
      var b when b is BitAssets => bitassetsStopping,
      var b when b is ZSide => zsideStopping,
      _ => false,
    };
  }

  Future<void> startWithEnforcer(
    Binary binaryToBoot, {
    bool bootExtraBinaryImmediately = false,
  }) async {
    final log = GetIt.I.get<Logger>();
    final startTime = DateTime.now();
    int getElapsed() => DateTime.now().difference(startTime).inMilliseconds;

    log.i('[T+0ms] STARTUP: Booting L1 binaries + ${binaryToBoot.name}');

    log.i('[T+${getElapsed()}ms] STARTUP: Ensuring all binaries are downloaded');

    // Ensure we have all required binaries
    final bitcoinCore = binaries.whereType<BitcoinCore>().firstOrNull;
    final enforcer = binaries.whereType<Enforcer>().firstOrNull;

    if (bitcoinCore == null || enforcer == null) {
      throw Exception('could not find all required L1 binaries');
    }

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
    if (settings.launcherMode) {
      while (true) {
        final walletDir = getWalletDir(bitwindowAppDir);
        if (walletDir != null) {
          final mnemonicFile = File(path.join(walletDir.path, 'l1_starter.txt'));
          if (await mnemonicFile.exists()) {
            break;
          }
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    await start(enforcer);
    log.i('[T+${getElapsed()}ms] STARTUP: Started enforcer');

    if (!bootExtraBinaryImmediately) {
      await start(binaryToBoot);
      log.i('[T+${getElapsed()}ms] STARTUP: Started ${binaryToBoot.name}');
    }

    log.i('[T+${getElapsed()}ms] STARTUP: All binaries started successfully');
  }

  // Add status stream for download progress
  Stream<Map<String, DownloadInfo>> get statusStream {
    return _downloadManager.progressStream;
  }

  Future<bool> onShutdown({ShutdownOptions? shutdownOptions}) async {
    try {
      // Get list of running binaries
      final runningBinaries = _processManager.runningProcesses.values.map((process) => process.binary).toList();

      if (shutdownOptions != null) {
        // don't show the shutting down page if it's already shown!
        if (shutdownOptions.router.current.name != ShuttingDownRoute.name) {
          // Show shutdown page with running binaries
          unawaited(
            shutdownOptions.router.push(
              ShuttingDownRoute(
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

      // After all binaries are asked nicely to stop, kill any lingering processes
      await _processManager.stopAll();
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
    // Watch the assets directory for changes
    _dirWatcher = binDir(appDir.path).watch(recursive: true).listen((event) async {
      switch (event.type) {
        case FileSystemEvent.create:
        case FileSystemEvent.delete:
          // Store original binaries to compare for changes
          final originalBinaries = List<Binary>.from(_downloadManager.binaries);

          // Reload metadata
          _downloadManager.binaries = await loadBinaryCreationTimestamp(_downloadManager.binaries, appDir);

          // Only notify if any binary metadata actually changed
          bool hasChanges = false;
          for (int i = 0; i < originalBinaries.length && i < _downloadManager.binaries.length; i++) {
            if (originalBinaries[i].metadata != _downloadManager.binaries[i].metadata) {
              hasChanges = true;
              break;
            }
          }

          if (hasChanges) {
            notifyListeners();
          }
          break;
        default:
          break;
      }
    });
  }

  Future<void> _checkReleaseDates() async {
    bool hasChanges = false;

    for (var i = 0; i < binaries.length; i++) {
      try {
        final binary = binaries[i];
        final serverReleaseDate = await binary.checkReleaseDate();
        if (serverReleaseDate != null) {
          final updatedConfig = binary.metadata.copyWith(
            remoteTimestamp: serverReleaseDate,
            downloadedTimestamp: binary.metadata.downloadedTimestamp,
            binaryPath: binary.metadata.binaryPath,
            updateable: binary.metadata.updateable,
          );

          // Only update and mark as changed if the config actually differs
          if (updatedConfig != binary.metadata) {
            binaries[i] = binary.copyWith(metadata: updatedConfig);
            hasChanges = true;
          }
        }
      } catch (e) {
        log.e('Error checking release date: $e');
        // Still notify even on error so UI can update error states
        hasChanges = true;
      }
    }

    // Only notify if there were actual changes
    if (hasChanges) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _releaseCheckTimer?.cancel();
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

  const ShutdownOptions({
    required this.router,
    required this.onComplete,
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
  final log = GetIt.I.get<Logger>();

  // now that assets are written, we can check stuff in parallel
  await Future.wait(
    binaries.asMap().entries.map((entry) async {
      final i = entry.key;
      final binary = entry.value;
      try {
        // Load metadata from bin/ in parallel
        final (lastModified, binaryFile) = await binary.getCreationDate(appDir);
        final updateableBinary = binaryFile?.path.contains(appDir.path) ?? false;

        DateTime? serverReleaseDate;
        try {
          serverReleaseDate = await binary.checkReleaseDate();
        } catch (e) {
          log.e('could not check release date: $e');
        }

        log.w('Loaded binary state for ${binary.name}: $lastModified $binaryFile $updateableBinary');

        final updatedConfig = binary.metadata.copyWith(
          remoteTimestamp: serverReleaseDate,
          downloadedTimestamp: lastModified,
          binaryPath: binaryFile,
          updateable: updateableBinary,
        );
        binaries[i] = binary.copyWith(metadata: updatedConfig);
      } catch (e) {
        // Log error but continue with other binaries
        GetIt.I.get<Logger>().e('Error loading binary state for ${binary.name}: $e');
      }
    }),
  );

  return binaries;
}

Directory binDir(String appDir) => Directory(path.join(appDir, 'assets', 'bin'));
