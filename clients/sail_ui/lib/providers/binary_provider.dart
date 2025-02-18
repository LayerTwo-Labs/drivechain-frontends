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
import 'package:sail_ui/style/color_scheme.dart';

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
  final bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  late final ThunderRPC? thunderRPC;
  late final BitnamesRPC? bitnamesRPC;

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
  bool get bitwindowConnected => bitwindowRPC.connected;
  bool get thunderConnected => thunderRPC?.connected ?? false;
  bool get bitnamesConnected => bitnamesRPC?.connected ?? false;
  bool get mainchainInitializing => mainchainRPC.initializingBinary;
  bool get enforcerInitializing => enforcerRPC.initializingBinary;
  bool get bitwindowInitializing => bitwindowRPC.initializingBinary;
  bool get thunderInitializing => thunderRPC?.initializingBinary ?? false;
  bool get bitnamesInitializing => bitnamesRPC?.initializingBinary ?? false;
  bool get mainchainStopping => mainchainRPC.stoppingBinary;
  bool get enforcerStopping => enforcerRPC.stoppingBinary;
  bool get bitwindowStopping => bitwindowRPC.stoppingBinary;
  bool get thunderStopping => thunderRPC?.stoppingBinary ?? false;
  bool get bitnamesStopping => bitnamesRPC?.stoppingBinary ?? false;

  // Only show errors for explicitly launched binaries
  String? get mainchainError => mainchainRPC.connectionError;
  String? get enforcerError => enforcerRPC.connectionError;
  String? get bitwindowError => bitwindowRPC.connectionError;
  String? get thunderError => thunderRPC?.connectionError;
  String? get bitnamesError => bitnamesRPC?.connectionError;

  bool get inIBD => mainchainRPC.inIBD;

  BinaryProvider({
    required this.appDir,
    required List<Binary> initialBinaries,
  }) {
    binaries = initialBinaries;
    _processProvider.addListener(notifyListeners);
    mainchainRPC.addListener(notifyListeners);
    enforcerRPC.addListener(notifyListeners);
    bitwindowRPC.addListener(notifyListeners);

    // Try to get optional RPCs
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
      _ => null, // No requirements for mainchain
    };
  }

  // Start a binary, and set starter seeds (if set)
  Future<void> startBinary(
    Binary binary, {
    bool useStarter = false,
    bool withBootConnectionRetry = false,
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
        await mainchainRPC.initBinary(withBootConnectionRetry: withBootConnectionRetry);

      case Enforcer():
        await enforcerRPC.initBinary(withBootConnectionRetry: withBootConnectionRetry);

      case BitWindow():
        await bitwindowRPC.initBinary(withBootConnectionRetry: withBootConnectionRetry);

      case Thunder():
        await thunderRPC?.initBinary(
          arg: binary.mnemonicSeedPhrasePath != null
              ? ['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]
              : null,
          withBootConnectionRetry: withBootConnectionRetry,
        );

      case Bitnames():
        await bitnamesRPC?.initBinary(
          arg: binary.mnemonicSeedPhrasePath != null
              ? ['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]
              : null,
          withBootConnectionRetry: withBootConnectionRetry,
        );

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
        await bitwindowRPC.stop();
      case Thunder():
        await thunderRPC?.stop();
      case Bitnames():
        await bitnamesRPC?.stop();
    }
  }

  bool isRunning(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainConnected,
      var b when b is Enforcer => enforcerConnected,
      var b when b is BitWindow => bitwindowConnected,
      var b when b is Thunder => thunderConnected,
      var b when b is Bitnames => bitnamesConnected,
      _ => false,
    };
  }

  bool isInitializing(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainRPC.initializingBinary,
      var b when b is Enforcer => enforcerRPC.initializingBinary,
      var b when b is BitWindow => bitwindowRPC.initializingBinary,
      var b when b is Thunder => thunderInitializing,
      var b when b is Bitnames => bitnamesInitializing,
      _ => false,
    };
  }

  bool isStopping(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainRPC.stoppingBinary,
      var b when b is Enforcer => enforcerRPC.stoppingBinary,
      var b when b is BitWindow => bitwindowRPC.stoppingBinary,
      var b when b is Thunder => thunderStopping,
      var b when b is Bitnames => bitnamesStopping,
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
      _ => false,
    };
  }

  Future<void> _downloadUninstalledL1Binaries() async {
    final uninstalledBinaries = binaries.where((b) => b.chainLayer == 1 && !b.isDownloaded);

    // Start downloads concurrently for uninstalled/failed binaries
    await Future.wait(
      uninstalledBinaries.map(
        (binary) => downloadBinary(binary),
      ),
    );
  }

  Future<void> downloadThenBootL1(
    BuildContext context, {
    bool bootAllNoMatterWhat = false,
    bool withEnforcerRetry = false,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final log = GetIt.I.get<Logger>();
    log.i('Booting L1 binaries in');

    try {
      // First ensure all binaries are downloaded
      await _downloadUninstalledL1Binaries();

      // Ensure we have all required binaries
      final parentChain = binaries.whereType<ParentChain>().firstOrNull;
      final enforcer = binaries.whereType<Enforcer>().firstOrNull;
      final bitwindow = binaries.whereType<BitWindow>().firstOrNull;

      if (parentChain == null || enforcer == null || bitwindow == null) {
        throw Exception('could not find all required L1 binaries');
      }

      // 1. Start parent chain and wait for IBD
      if (!context.mounted) return;
      await startBinary(parentChain, useStarter: false);

      log.i('Waiting for mainchain to connect...');
      await mainchainRPC.waitForHeaderSync();
      log.i('Mainchain headers synced, starting enforcer');

      // 2. Start rest after mainchain is ready
      if (bootAllNoMatterWhat) {
        // 2.1. If we're told to boot no matter what, do enforcer and bitwindow in parallell
        if (!context.mounted) return;
        unawaited(startBinary(bitwindow, useStarter: false));
        await startBinary(
          enforcer,
          useStarter: false,
          withBootConnectionRetry: withEnforcerRetry,
        );
        log.i('Started enforcer and bitwindow');
      } else {
        // 2.2. We're told to NOT be fast. Ensure enforcer is started first
        if (!context.mounted) return;
        await startBinary(
          enforcer,
          useStarter: false,
          withBootConnectionRetry: withEnforcerRetry,
        );
        log.i('Started enforcer');

        // 3. Start BitWindow after enforcer
        if (!context.mounted) return;
        await startBinary(bitwindow, useStarter: false);
        log.i('Started BitWindow');
      }

      log.i('All L1 binaries started successfully');
    } catch (e) {
      log.e('Error starting L1 binaries: $e');
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to start L1 binaries: $e'),
            backgroundColor: SailColorScheme.red,
          ),
        );
      }
      rethrow; // Re-throw to indicate failure
    }
  }

  @override
  void dispose() {
    _dirWatcher?.cancel();
    _releaseCheckTimer?.cancel();
    mainchainRPC.removeListener(notifyListeners);
    enforcerRPC.removeListener(notifyListeners);
    bitwindowRPC.removeListener(notifyListeners);
    thunderRPC?.removeListener(notifyListeners);
    bitnamesRPC?.removeListener(notifyListeners);
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
