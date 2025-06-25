import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/providers/binaries/download_manager.dart';
import 'package:sail_ui/providers/binaries/process_manager.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/zcash_rpc.dart';

/// Manages downloads, installations and running of binaries
class BinaryProvider extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;

  final mainchainRPC = GetIt.I.get<MainchainRPC>();
  final enforcerRPC = GetIt.I.get<EnforcerRPC>();

  late final BitwindowRPC? bitwindowRPC;
  late final ThunderRPC? thunderRPC;
  late final BitnamesRPC? bitnamesRPC;
  late final BitAssetsRPC? bitassetsRPC;
  late final ZCashRPC? zcashRPC;
  late final DownloadManager _downloadManager;
  late final ProcessManager _processManager;

  StreamSubscription<FileSystemEvent>? _dirWatcher;
  Timer? _releaseCheckTimer;

  // Connection status getters
  bool get mainchainConnected => mainchainRPC.connected;
  bool get enforcerConnected => enforcerRPC.connected;
  bool get bitwindowConnected => bitwindowRPC?.connected ?? false;
  bool get thunderConnected => thunderRPC?.connected ?? false;
  bool get bitnamesConnected => bitnamesRPC?.connected ?? false;
  bool get bitassetsConnected => bitassetsRPC?.connected ?? false;
  bool get zcashConnected => zcashRPC?.connected ?? false;

  bool get mainchainInitializing => mainchainRPC.initializingBinary;
  bool get enforcerInitializing => enforcerRPC.initializingBinary;
  bool get bitwindowInitializing => bitwindowRPC?.initializingBinary ?? false;
  bool get thunderInitializing => thunderRPC?.initializingBinary ?? false;
  bool get bitnamesInitializing => bitnamesRPC?.initializingBinary ?? false;
  bool get bitassetsInitializing => bitassetsRPC?.initializingBinary ?? false;
  bool get zcashInitializing => zcashRPC?.initializingBinary ?? false;

  bool get mainchainStopping => mainchainRPC.stoppingBinary;
  bool get enforcerStopping => enforcerRPC.stoppingBinary;
  bool get bitwindowStopping => bitwindowRPC?.stoppingBinary ?? false;
  bool get thunderStopping => thunderRPC?.stoppingBinary ?? false;
  bool get bitnamesStopping => bitnamesRPC?.stoppingBinary ?? false;
  bool get bitassetsStopping => bitassetsRPC?.stoppingBinary ?? false;
  bool get zcashStopping => zcashRPC?.stoppingBinary ?? false;

  // Only show errors for explicitly launched binaries
  String? get mainchainError => mainchainRPC.connectionError;
  String? get enforcerError => enforcerRPC.connectionError;
  String? get bitwindowError => bitwindowRPC?.connectionError;
  String? get thunderError => thunderRPC?.connectionError;
  String? get bitnamesError => bitnamesRPC?.connectionError;
  String? get bitassetsError => bitassetsRPC?.connectionError;
  String? get zcashError => zcashRPC?.connectionError;

  // Only show errors for explicitly launched binaries
  String? get mainchainStartupError => mainchainRPC.startupError;
  String? get enforcerStartupError => enforcerRPC.startupError;
  String? get bitwindowStartupError => bitwindowRPC?.startupError;
  String? get thunderStartupError => thunderRPC?.startupError;
  String? get bitnamesStartupError => bitnamesRPC?.startupError;
  String? get bitassetsStartupError => bitassetsRPC?.startupError;
  String? get zcashStartupError => zcashRPC?.startupError;

  // let the download manager handle all binary stuff. Only it does updates!
  List<Binary> get binaries => _downloadManager.binaries;
  ExitTuple? exited(Binary binary) => _processManager.exited(binary);

  Stream<String> stderr(Binary binary) => _processManager.stderr(binary);

  // Track starter usage for L2 chains
  final Map<String, bool> _useStarter = {};
  void setUseStarter(Binary binary, bool value) {
    _useStarter[binary.name] = value;
    notifyListeners();
  }

  BinaryProvider({
    required this.appDir,
    required List<Binary> initialBinaries,
  }) {
    _downloadManager = DownloadManager(
      appDir: appDir,
      binaries: initialBinaries,
      updateBinary: (name, updater) {
        final index = binaries.indexWhere((b) => b.name == name);
        if (index >= 0) {
          binaries[index] = updater(binaries[index]);
        }
      },
    );
    _processManager = ProcessManager(
      appDir: appDir,
    );

    // Forward DownloadManager notifications to BinaryProvider listeners
    _processManager.addListener(notifyListeners);
    mainchainRPC.addListener(notifyListeners);
    enforcerRPC.addListener(notifyListeners);

    // Then try to register optional RPCs
    try {
      bitwindowRPC = GetIt.I.get<BitwindowRPC>();
      bitwindowRPC?.addListener(notifyListeners);
    } catch (_) {
      bitwindowRPC = null;
    }

    try {
      thunderRPC = GetIt.I.get<ThunderRPC>();
      thunderRPC?.addListener(notifyListeners);
    } catch (_) {
      thunderRPC = null;
    }

    try {
      bitnamesRPC = GetIt.I.get<BitnamesRPC>();
      bitnamesRPC?.addListener(notifyListeners);
    } catch (_) {
      bitnamesRPC = null;
    }

    try {
      bitassetsRPC = GetIt.I.get<BitAssetsRPC>();
      bitassetsRPC?.addListener(notifyListeners);
    } catch (_) {
      bitassetsRPC = null;
    }

    try {
      zcashRPC = GetIt.I.get<ZCashRPC>();
      zcashRPC?.addListener(notifyListeners);
    } catch (_) {
      zcashRPC = null;
    }

    _init();
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

    _setupDirectoryWatcher();
    await _checkReleaseDates();
    // now that we have the release date and binary date, (if any) we can check
    // for updates/missing binaries
    await Future.wait(binaries.map((b) => _downloadManager.downloadIfMissing(b)));
  }

  // Start a binary, and set starter seeds (if set)
  Future<void> start(
    Binary binary, {
    bool useStarter = false,
  }) async {
    await _downloadManager.downloadIfMissing(binary);

    if (binary is Thunder || binary is Bitnames || binary is BitAssets) {
      binary = binary as Sidechain;
      // We're booting some sort of sidechain. Check the launcher-directory for
      // a starter seed
      final mnemonicPath = binary.getMnemonicPath(appDir);
      if (mnemonicPath != null) {
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
      var b when b is ZCash => zcashRPC,
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
        // zcash can take a long time. initial sync as well
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
          final logs = await stderr(binary).toList();
          log.e('$binary exited before we could connect, dumping logs');
          for (var line in logs) {
            log.e('$binary: $line');
          }

          var lastLine = _stripFromString(logs.last, ': ');
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
          await mainchainRPC.stop();
        case Enforcer():
          await enforcerRPC.stop();
        case BitWindow():
          await bitwindowRPC?.stop();
        case Thunder():
          await thunderRPC?.stop();
        case Bitnames():
          await bitnamesRPC?.stop();
        case BitAssets():
          await bitassetsRPC?.stop();
        case ZCash():
          await zcashRPC?.stop();
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
  Future<void> download(Binary binary) async {
    await _downloadManager.downloadIfMissing(binary);
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
      var b when b is ZCash => zcashConnected,
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
      var b when b is ZCash => zcashInitializing,
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
      var b when b is ZCash => zcashError,
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
      var b when b is ZCash => _processManager.isRunning(ZCash()),
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
      var b when b is ZCash => zcashStopping,
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
      unawaited(
        start(
          binaryToBoot,
          useStarter: false,
        ),
      );
    }

    await start(bitcoinCore, useStarter: false);
    log.i('[T+${getElapsed()}ms] STARTUP: Started bitcoin core...');

    await start(
      enforcer,
      useStarter: false,
    );
    log.i('[T+${getElapsed()}ms] STARTUP: Started enforcer');

    if (!bootExtraBinaryImmediately) {
      await start(
        binaryToBoot,
        useStarter: false,
      );
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
    final assetsDir = Directory(path.join(appDir.path, 'bin'));
    _dirWatcher = assetsDir.watch(recursive: true).listen((event) async {
      switch (event.type) {
        case FileSystemEvent.create:
        case FileSystemEvent.delete:
          // Always reload metadata and notify when files change
          _downloadManager.binaries = await loadBinaryCreationTimestamp(_downloadManager.binaries, appDir);
          notifyListeners(); // Notify immediately after metadata reload
          break;
        default:
          break;
      }
    });
  }

  Future<void> _checkReleaseDates() async {
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
          binaries[i] = binary.copyWith(metadata: updatedConfig);

          // Notify immediately after each binary update
          notifyListeners();
        }
      } catch (e) {
        log.e('Error checking release date: $e');
        // Still notify even on error so UI can update error states
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _releaseCheckTimer?.cancel();
    _dirWatcher?.cancel();
    _downloadManager.removeListener(notifyListeners);
    mainchainRPC.removeListener(notifyListeners);
    enforcerRPC.removeListener(notifyListeners);
    bitwindowRPC?.removeListener(notifyListeners);
    thunderRPC?.removeListener(notifyListeners);
    bitnamesRPC?.removeListener(notifyListeners);
    bitassetsRPC?.removeListener(notifyListeners);
    zcashRPC?.removeListener(notifyListeners);
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
  for (var i = 0; i < binaries.length; i++) {
    final binary = binaries[i];
    try {
      // Load metadata from bin/
      final (lastModified, binaryFile) = await binary.getCreationDate(appDir);
      final updateableBinary = binaryFile?.path.contains(appDir.path) ?? false;

      final updatedConfig = binary.metadata.copyWith(
        remoteTimestamp: binary.metadata.remoteTimestamp,
        downloadedTimestamp: lastModified,
        binaryPath: binaryFile,
        updateable: updateableBinary,
      );
      binaries[i] = binary.copyWith(metadata: updatedConfig);
    } catch (e) {
      // Log error but continue with other binaries
      GetIt.I.get<Logger>().e('Error loading binary state for ${binary.name}: $e');
    }
  }

  return binaries;
}

Directory binDir(String appDir) => Directory(path.join(appDir, 'assets', 'bin'));
