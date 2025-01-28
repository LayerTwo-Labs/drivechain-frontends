import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
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

  final mainchainRPC = GetIt.I.get<MainchainRPC>();
  final enforcerRPC = GetIt.I.get<EnforcerRPC>();
  final bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  final thunderRPC = GetIt.I.get<ThunderRPC>();
  final bitnamesRPC = GetIt.I.get<BitnamesRPC>();

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
  bool get thunderConnected => thunderRPC.connected;
  bool get bitnamesConnected => bitnamesRPC.connected;
  bool get mainchainInitializing => mainchainRPC.initializingBinary;
  bool get enforcerInitializing => enforcerRPC.initializingBinary;
  bool get bitwindowInitializing => bitwindowRPC.initializingBinary;
  bool get thunderInitializing => thunderRPC.initializingBinary;
  bool get bitnamesInitializing => bitnamesRPC.initializingBinary;
  bool get mainchainStopping => mainchainRPC.stoppingBinary;
  bool get enforcerStopping => enforcerRPC.stoppingBinary;
  bool get bitwindowStopping => bitwindowRPC.stoppingBinary;
  bool get thunderStopping => thunderRPC.stoppingBinary;
  bool get bitnamesStopping => bitnamesRPC.stoppingBinary;

  // Add a flag to track if binaries were explicitly launched
  final Map<String, bool> _explicitlyLaunched = {};

  // Only show errors for explicitly launched binaries
  String? get mainchainError => _explicitlyLaunched[ParentChain().name] == true ? mainchainRPC.connectionError : null;
  String? get enforcerError => _explicitlyLaunched[Enforcer().name] == true ? enforcerRPC.connectionError : null;
  String? get bitwindowError => _explicitlyLaunched[BitWindow().name] == true ? bitwindowRPC.connectionError : null;
  String? get thunderError => _explicitlyLaunched[Thunder().name] == true ? thunderRPC.connectionError : null;
  String? get bitnamesError => _explicitlyLaunched[Bitnames().name] == true ? bitnamesRPC.connectionError : null;

  bool get inIBD => mainchainRPC.inIBD;

  BinaryProvider({
    required this.appDir,
    required List<Binary> initialBinaries,
  }) {
    binaries = initialBinaries;
    mainchainRPC.addListener(notifyListeners);
    enforcerRPC.addListener(notifyListeners);
    bitwindowRPC.addListener(notifyListeners);
    thunderRPC.addListener(notifyListeners);
    bitnamesRPC.addListener(notifyListeners);

    _setupDirectoryWatcher();
    _checkReleaseDates();
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
          final updatedConfig = binary.download.copyWith(
            remoteTimestamp: serverReleaseDate,
            downloadedTimestamp: binary.download.downloadedTimestamp,
          );
          binaries[i] = binary.copyWith(download: updatedConfig);
        }
      } catch (e) {
        log.e('Error checking release date: $e');
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

  // Start a binary, and set starter seeds (if set)
  Future<void> startBinary(BuildContext context, Binary binary, {bool useStarter = false}) async {
    if (!context.mounted) return;

    if (useStarter && (binary is Thunder || binary is Bitnames)) {
      try {
        await _setStarterSeed(binary);
      } catch (e) {
        log.e('Error setting starter seed: $e');
      }
    }

    switch (binary) {
      case ParentChain():
        await mainchainRPC.initBinary(context);

      case Enforcer():
        await enforcerRPC.initBinary(context);

      case BitWindow():
        await bitwindowRPC.initBinary(context);

      case Thunder():
        await thunderRPC.initBinary(
          context,
          arg: binary.mnemonicSeedPhrasePath != null 
            ? ['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]
            : null,
        );

      case Bitnames():
        await bitnamesRPC.initBinary(
          context,
          arg: binary.mnemonicSeedPhrasePath != null 
            ? ['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]
            : null,
        );

      default:
        log.i('is $binary');
    }
    Future.delayed(const Duration(seconds: 3), () {
      // give it a bit of time to clean fucked up error messages
      _explicitlyLaunched[binary.name] = true;
      notifyListeners();
    });

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

  /// Check if a binary can be started based on its dependencies
  String? canStart(Binary binary) {
    return switch (binary) {
      Enforcer() =>
        mainchainConnected && !inIBD ? null : 'Mainchain must be started and fully synced before starting Enforcer',
      BitWindow() => enforcerConnected ? null : 'Enforcer must be running and fully synced before starting BitWindow',
      Thunder() => enforcerConnected ? null : 'Enforcer must be running and fully synced before starting Thunder',
      Bitnames() => enforcerConnected ? null : 'Enforcer must be running and fully synced before starting Bitnames',
      _ => null, // No requirements for mainchain
    };
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
      // Skip if mnemonic path is already set
      if (binary.mnemonicSeedPhrasePath != null) {
        log.i('Sidechain ${binary.name} already has mnemonic path set, skipping seed setup');
        return;
      }

      // Check if this sidechain has already been initialized
      final isInitialized = await _isSidechainInitialized(binary.slot);
      if (isInitialized) {
        log.i('Sidechain ${binary.name} already initialized, skipping seed setup');
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
    _explicitlyLaunched[binary.name] = false;
    switch (binary) {
      case ParentChain():
        await mainchainRPC.stop();
      case Enforcer():
        await enforcerRPC.stop();
      case BitWindow():
        await bitwindowRPC.stop();
      case Thunder():
        await thunderRPC.stop();
      case Bitnames():
        await bitnamesRPC.stop();
    }
  }

  @override
  void dispose() {
    _dirWatcher?.cancel();
    mainchainRPC.removeListener(notifyListeners);
    enforcerRPC.removeListener(notifyListeners);
    bitwindowRPC.removeListener(notifyListeners);
    thunderRPC.removeListener(notifyListeners);
    bitnamesRPC.removeListener(notifyListeners);
    super.dispose();
  }
}

Future<List<Binary>> loadBinaryMetadata(List<Binary> binaries, Directory appDir) async {
  for (var i = 0; i < binaries.length; i++) {
    final binary = binaries[i];
    try {
      // Load metadata from assets/
      final metadata = await binary.loadMetadata(appDir);

      final updatedConfig = binary.download.copyWith(
        remoteTimestamp: binary.download.remoteTimestamp,
        downloadedTimestamp: metadata?.releaseDate,
      );
      binaries[i] = binary.copyWith(download: updatedConfig);
    } catch (e) {
      // Log error but continue with other binaries
      GetIt.I.get<Logger>().e('Error loading binary state for ${binary.name}: $e');
    }
  }

  return binaries;
}
