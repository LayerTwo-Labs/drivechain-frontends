import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/providers/process_provider.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/zcash_rpc.dart';

/// Represents the current status of a binary download
class DownloadState {
  final double progress; // Only used during installing
  final String? message; // Progress message or installation date
  final String? error; // Error message if installation failed

  const DownloadState({
    this.progress = 0.0,
    this.message,
    this.error,
  });
}

/// Manages downloads and installations of binaries
class BinaryProvider extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;
  late List<Binary> binaries;
  StreamSubscription<FileSystemEvent>? _dirWatcher;
  Timer? _releaseCheckTimer;

  final _processProvider = GetIt.I.get<ProcessProvider>();
  final mainchainRPC = GetIt.I.get<MainchainRPC>();
  final enforcerRPC = GetIt.I.get<EnforcerRPC>();
  late final BitwindowRPC? bitwindowRPC;
  late final ThunderRPC? thunderRPC;
  late final BitnamesRPC? bitnamesRPC;
  late final ZCashRPC? zcashRPC;

  // Track download status and active downloads for each binary
  final _downloadStates = <String, DownloadState>{};
  final _activeDownloads = <String, bool>{}; // Track per-binary downloads

  // Stream controller for status updates
  final _statusController = StreamController<Map<String, DownloadState>>.broadcast();
  Stream<Map<String, DownloadState>> get statusStream => _statusController.stream;

  // Track starter usage for L2 chains
  final Map<String, bool> _useStarter = {};
  bool shouldUseStarter(Binary binary) => _useStarter[binary.name] ?? false;
  void setUseStarter(Binary binary, bool value) {
    _useStarter[binary.name] = value;
    notifyListeners();
  }

  // Connection status getters
  bool get mainchainConnected => mainchainRPC.connected;
  bool get enforcerConnected => enforcerRPC.connected;
  bool get bitwindowConnected => bitwindowRPC?.connected ?? false;
  bool get thunderConnected => thunderRPC?.connected ?? false;
  bool get bitnamesConnected => bitnamesRPC?.connected ?? false;
  bool get zcashConnected => zcashRPC?.connected ?? false;

  bool get mainchainInitializing => mainchainRPC.initializingBinary;
  bool get enforcerInitializing => enforcerRPC.initializingBinary;
  bool get bitwindowInitializing => bitwindowRPC?.initializingBinary ?? false;
  bool get thunderInitializing => thunderRPC?.initializingBinary ?? false;
  bool get bitnamesInitializing => bitnamesRPC?.initializingBinary ?? false;
  bool get zcashInitializing => zcashRPC?.initializingBinary ?? false;

  bool get mainchainStopping => mainchainRPC.stoppingBinary;
  bool get enforcerStopping => enforcerRPC.stoppingBinary;
  bool get bitwindowStopping => bitwindowRPC?.stoppingBinary ?? false;
  bool get thunderStopping => thunderRPC?.stoppingBinary ?? false;
  bool get bitnamesStopping => bitnamesRPC?.stoppingBinary ?? false;
  bool get zcashStopping => zcashRPC?.stoppingBinary ?? false;

  // Only show errors for explicitly launched binaries
  String? get mainchainError => mainchainRPC.connectionError;
  String? get enforcerError => enforcerRPC.connectionError;
  String? get bitwindowError => bitwindowRPC?.connectionError;
  String? get thunderError => thunderRPC?.connectionError;
  String? get bitnamesError => bitnamesRPC?.connectionError;
  String? get zcashError => zcashRPC?.connectionError;

  // Only show errors for explicitly launched binaries
  String? get mainchainStartupError => mainchainRPC.startupError;
  String? get enforcerStartupError => enforcerRPC.startupError;
  String? get bitwindowStartupError => bitwindowRPC?.startupError;
  String? get thunderStartupError => thunderRPC?.startupError;
  String? get bitnamesStartupError => bitnamesRPC?.startupError;
  String? get zcashStartupError => zcashRPC?.startupError;

  bool get inIBD => mainchainRPC.inIBD;

  BinaryProvider({
    required this.appDir,
    required List<Binary> initialBinaries,
  }) {
    binaries = initialBinaries;
    _processProvider.addListener(notifyListeners);
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
      zcashRPC = GetIt.I.get<ZCashRPC>();
      zcashRPC?.addListener(notifyListeners);
    } catch (_) {
      zcashRPC = null;
    }

    _setupDirectoryWatcher();
    _checkReleaseDates();

    // Set up periodic release date checks
    if (!Environment.isInTest) {
      _releaseCheckTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _checkReleaseDates(),
      );
    }
  }

  void _setupDirectoryWatcher() {
    // Watch the assets directory for changes
    final assetsDir = Directory(path.join(appDir.path, 'assets'));
    _dirWatcher = assetsDir.watch(recursive: true).listen((event) async {
      if (_activeDownloads.values.any((active) => active)) {
        // Skip if there are any active downloads
        return;
      }

      switch (event.type) {
        case FileSystemEvent.create:
        case FileSystemEvent.delete:
          // reload metadata when a file is created or deleted
          binaries = await loadBinaryMetadata(binaries, appDir);
          notifyListeners();
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
          );
          binaries[i] = binary.copyWith(metadata: updatedConfig);
        }
      } catch (e) {
        log.e('Error checking release date: $e');
      } finally {
        notifyListeners();
      }
    }
  }

  /// Get all L1 chain configurations
  List<Binary> getL1Chains() {
    return binaries.where((chain) => chain.chainLayer == 1).toList();
  }

  /// Get all L2 chain configurations
  List<Binary> getL2Chains() {
    return binaries.where((chain) => chain.chainLayer == 2).toList();
  }

  /// Update status for a binary
  void _updateStatus(
    Binary binary, {
    double progress = 0.0,
    String? message,
    String? error,
  }) {
    _downloadStates[binary.name] = DownloadState(
      progress: progress,
      message: message,
      error: error,
    );
    _statusController.add(Map.from(_downloadStates));
  }

  /// Check if a binary can be started based on its dependencies
  String? canStart(Binary binary) {
    final mainchainReady = mainchainConnected && !mainchainRPC.inHeaderSync;
    return switch (binary) {
      Enforcer() => mainchainReady ? null : 'Mainchain must be started and headers synced before starting Enforcer',
      BitWindow() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting BitWindow',
      Thunder() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting Thunder',
      Bitnames() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting Bitnames',
      ZCash() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting ZCash',
      _ => null, // No requirements for mainchain
    };
  }

  // Start a binary, and set starter seeds (if set)
  Future<void> startBinary(
    Binary binary, {
    bool useStarter = false,
  }) async {
    if (useStarter && (binary is Thunder || binary is Bitnames)) {
      try {
        await _setStarterSeed(binary);
      } catch (e) {
        log.e('Error setting starter seed: $e');
      }
    }

    switch (binary) {
      case ParentChain():
        await mainchainRPC.initBinary();

      case Enforcer():
        await enforcerRPC.initBinary();

      case BitWindow():
        await bitwindowRPC?.initBinary();

      case Thunder():
        await thunderRPC?.initBinary(
          arg: binary.mnemonicSeedPhrasePath != null
              ? ['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]
              : null,
        );

      case Bitnames():
        await bitnamesRPC?.initBinary(
          arg: binary.mnemonicSeedPhrasePath != null
              ? ['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]
              : null,
        );

      case ZCash():
        await zcashRPC?.initBinary();

      default:
        log.i('is $binary');
    }
    // Wait for connection or timeout
    await Future.any([
      () async {
        while (!_isConnected(binary)) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }(),
      Future.delayed(const Duration(seconds: 60)),
    ]);

    log.i('${binary.name} started successfully');
    notifyListeners();
  }

  bool _isConnected(Binary binary) {
    return switch (binary) {
      ParentChain() => mainchainConnected,
      Enforcer() => enforcerConnected,
      BitWindow() => bitwindowConnected,
      Thunder() => thunderConnected,
      Bitnames() => bitnamesConnected,
      ZCash() => zcashConnected,
      _ => false,
    };
  }

  Future<void> downloadBinary(Binary binary) async {
    // Check if already downloading
    if (_activeDownloads[binary.name] == true) {
      return;
    }

    _activeDownloads[binary.name] = true;
    try {
      await binary.downloadAndExtract(
        appDir,
        ({progress = 0.0, message, error}) {
          _updateStatus(
            binary,
            progress: progress,
            message: message,
            error: error,
          );
        },
      );
    } finally {
      try {
        // Only clean up if this was the only active download
        if (_activeDownloads.values.where((active) => active).length == 1) {
          await _cleanUp(appDir);
        }
      } finally {
        binaries = await loadBinaryMetadata(binaries, appDir);
        _activeDownloads[binary.name] = false;
        notifyListeners();
      }
    }
  }

  Future<void> _cleanUp(Directory datadir) async {
    final downloadsDir = Directory(path.join(datadir.path, 'assets', 'downloads'));
    await downloadsDir.delete(recursive: true);
  }

  Future<bool> _isSidechainInitialized(int slot) async {
    try {
      final masterStarterPath = path.join(appDir.path, 'wallet_starters', 'master_starter.json');
      final masterStarterFile = File(masterStarterPath);

      if (!masterStarterFile.existsSync()) {
        return false;
      }

      final masterData = jsonDecode(await masterStarterFile.readAsString()) as Map<String, dynamic>;
      return masterData['sidechain_${slot}_init'] ?? false;
    } catch (e) {
      log.e('Error checking sidechain initialization: $e');
      return false;
    }
  }

  Future<void> _setSidechainInitialized(int slot) async {
    try {
      final masterStarterPath = path.join(appDir.path, 'wallet_starters', 'master_starter.json');
      final masterStarterFile = File(masterStarterPath);

      if (!masterStarterFile.existsSync()) {
        return;
      }

      final masterData = jsonDecode(await masterStarterFile.readAsString()) as Map<String, dynamic>;
      masterData['sidechain_${slot}_init'] = true;
      await masterStarterFile.writeAsString(jsonEncode(masterData));
    } catch (e) {
      log.e('Error setting sidechain initialization: $e');
    }
  }

  Future<void> _setStarterSeed(Binary binary) async {
    if (binary is! Sidechain) return;

    try {
      // Check if this sidechain has already been initialized
      final isInitialized = await _isSidechainInitialized(binary.slot);
      if (isInitialized) {
        log.i('Sidechain ${binary.name} already initialized, skipping seed setup');
        return;
      }

      // Skip if mnemonic path is already set
      if (binary.mnemonicSeedPhrasePath != null) {
        log.i('Sidechain ${binary.name} already has mnemonic path set, skipping seed setup');
        return;
      }

      final starterDir = path.join(appDir.path, 'wallet_starters');
      final starterFile = File(
        path.join(
          starterDir,
          'sidechain_${binary.slot}_starter.txt',
        ),
      );

      if (!starterFile.existsSync()) {
        log.i('No starter file found for ${binary.name}');
        return;
      }

      log.i('Found starter file, setting mnemonic seed phrase path');
      binary.mnemonicSeedPhrasePath = starterFile.path;
      log.i('Successfully set mnemonic seed phrase path to: ${starterFile.path}');

      // Mark this sidechain as initialized
      await _setSidechainInitialized(binary.slot);
      notifyListeners();
    } catch (e, st) {
      log.e('Error setting starter seed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> stop(Binary binary) async {
    switch (binary) {
      case ParentChain():
        await mainchainRPC.stop();
      case Enforcer():
        await enforcerRPC.stop();
      case BitWindow():
        await bitwindowRPC?.stop();
      case Thunder():
        await thunderRPC?.stop();
      case Bitnames():
        await bitnamesRPC?.stop();
      case ZCash():
        await zcashRPC?.stop();
    }
  }

  bool isRunning(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainConnected,
      var b when b is Enforcer => enforcerConnected,
      var b when b is BitWindow => bitwindowConnected,
      var b when b is Thunder => thunderConnected,
      var b when b is Bitnames => bitnamesConnected,
      var b when b is ZCash => zcashConnected,
      _ => false,
    };
  }

  bool isInitializing(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainInitializing,
      var b when b is Enforcer => enforcerInitializing,
      var b when b is BitWindow => bitwindowInitializing,
      var b when b is Thunder => thunderInitializing,
      var b when b is Bitnames => bitnamesInitializing,
      var b when b is ZCash => zcashInitializing,
      _ => false,
    };
  }

  bool isStopping(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainStopping,
      var b when b is Enforcer => enforcerStopping,
      var b when b is BitWindow => bitwindowStopping,
      var b when b is Thunder => thunderStopping,
      var b when b is Bitnames => bitnamesStopping,
      var b when b is ZCash => zcashStopping,
      _ => false,
    };
  }

  bool isProcessRunning(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => _processProvider.isRunning(ParentChain()),
      var b when b is Enforcer => _processProvider.isRunning(Enforcer()),
      var b when b is BitWindow => _processProvider.isRunning(BitWindow()),
      var b when b is Thunder => _processProvider.isRunning(Thunder()),
      var b when b is Bitnames => _processProvider.isRunning(Bitnames()),
      var b when b is ZCash => _processProvider.isRunning(ZCash()),
      _ => false,
    };
  }

  Future<void> _downloadUninstalledBinaries(Binary binaryToBoot) async {
    final log = GetIt.I.get<Logger>();
    log.i('Starting download of uninstalled binaries');

    var uninstalledBinaries = binaries.where((b) => b.chainLayer == 1 && !b.isDownloaded).toList();
    log.i('Found ${uninstalledBinaries.length} uninstalled L1 binaries');

    if (!binaryToBoot.isDownloaded) {
      log.i('Adding ${binaryToBoot.name} to download queue');
      uninstalledBinaries.add(binaryToBoot);
    }

    if (uninstalledBinaries.isEmpty) {
      log.i('No binaries to download');
      return;
    }

    // Start downloads concurrently for uninstalled/failed binaries
    log.i('Starting concurrent downloads for ${uninstalledBinaries.length} binaries');
    await Future.wait(
      uninstalledBinaries.map(
        (binary) => downloadBinary(binary),
      ),
    );
    log.i('Completed all binary downloads');
  }

  Future<void> downloadThenBootBinary(
    Binary binaryToBoot, {
    bool bootAllNoMatterWhat = false,
  }) async {
    final log = GetIt.I.get<Logger>();
    final startTime = DateTime.now();
    int getElapsed() => DateTime.now().difference(startTime).inMilliseconds;

    log.i('[T+0ms] STARTUP: Booting L1 binaries + ${binaryToBoot.name}');

    // First ensure all binaries are downloaded
    await _downloadUninstalledBinaries(binaryToBoot);

    log.i('[T+${getElapsed()}ms] STARTUP: Ensuring all binaries are downloaded');

    // Ensure we have all required binaries
    final parentChain = binaries.whereType<ParentChain>().firstOrNull;
    final enforcer = binaries.whereType<Enforcer>().firstOrNull;

    if (parentChain == null || enforcer == null) {
      throw Exception('could not find all required L1 binaries');
    }

    if (bootAllNoMatterWhat) {
      // 2.1. If we're told to boot no matter what, do enforcer and bitwindow in parallell
      log.i('[T+${getElapsed()}ms] STARTUP: Starting ${binaryToBoot.name}');
      unawaited(
        startBinary(
          binaryToBoot,
          useStarter: false,
        ),
      );
    }

    // 1. Start parent chain and wait for IBD
    // parent chain does not need to be restarted on crash, it's very stable
    await startBinary(parentChain, useStarter: false);

    log.i('[T+${getElapsed()}ms] STARTUP: Waiting for mainchain to connect...');
    await mainchainRPC.waitForHeaderSync();
    log.i('[T+${getElapsed()}ms] STARTUP: Mainchain headers synced, starting enforcer');

    // 2. Start rest after mainchain is ready
    await startBinary(
      enforcer,
      useStarter: false,
    );
    log.i('[T+${getElapsed()}ms] STARTUP: Started enforcer');

    if (!bootAllNoMatterWhat) {
      // 3. Start whatever binary we were told to boot after enforcer
      await startBinary(
        binaryToBoot,
        useStarter: false,
      );
      log.i('[T+${getElapsed()}ms] STARTUP: Started ${binaryToBoot.name}');
    }

    log.i('[T+${getElapsed()}ms] STARTUP: All binaries started successfully');
  }

  @override
  void dispose() {
    _dirWatcher?.cancel();
    _releaseCheckTimer?.cancel();
    mainchainRPC.removeListener(notifyListeners);
    enforcerRPC.removeListener(notifyListeners);
    bitwindowRPC?.removeListener(notifyListeners);
    thunderRPC?.removeListener(notifyListeners);
    bitnamesRPC?.removeListener(notifyListeners);
    zcashRPC?.removeListener(notifyListeners);
    super.dispose();
  }
}

Future<List<Binary>> loadBinaryMetadata(List<Binary> binaries, Directory appDir) async {
  for (var i = 0; i < binaries.length; i++) {
    final binary = binaries[i];
    try {
      // Load metadata from assets/
      final (metadata, binaryFile) = await binary.loadMetadata(appDir);

      final updatedConfig = binary.metadata.copyWith(
        remoteTimestamp: binary.metadata.remoteTimestamp,
        downloadedTimestamp: metadata?.releaseDate,
        binaryPath: binaryFile,
      );
      binaries[i] = binary.copyWith(metadata: updatedConfig);
    } catch (e) {
      // Log error but continue with other binaries
      GetIt.I.get<Logger>().e('Error loading binary state for ${binary.name}: $e');
    }
  }

  return binaries;
}
