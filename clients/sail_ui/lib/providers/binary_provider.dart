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
  final DownloadStatus status;
  final double progress; // Only used during installing
  final String? message; // Progress message or installation date
  final String? error; // Error message if installation failed

  const DownloadState({
    this.status = DownloadStatus.uninstalled,
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

    initialize();
    _setupDirectoryWatcher();
  }

  void _setupDirectoryWatcher() {
    // Watch the assets directory for changes
    final assetsDir = Directory(path.join(appDir.path, 'assets'));
    _dirWatcher = assetsDir.watch(recursive: true).listen((event) {
      // Skip if there are any active downloads
      if (_activeDownloads.values.any((active) => active)) {
        return;
      }

      switch (event.type) {
        case FileSystemEvent.create:
        case FileSystemEvent.delete:
        case FileSystemEvent.modify:
          initialize();
          break;
        default:
          break;
      }
    });
  }

  /// Initialize download states for all binaries
  Future<void> initialize() async {
    // First set initial states synchronously
    for (final binary in binaries) {
      _downloadStates[binary.name] = DownloadState(
        status: binary.download.downloadedTimestamp != null ? DownloadStatus.installed : DownloadStatus.uninstalled,
        message: binary.download.downloadedTimestamp != null
            ? 'Installed (${binary.download.downloadedTimestamp!.toLocal()})'
            : null,
      );
    }

    // Emit initial states immediately
    _statusController.add(Map.from(_downloadStates));

    // Then check release dates in the background
    unawaited(_checkReleaseDates());
  }

  Future<void> _checkReleaseDates() async {
    for (var i = 0; i < binaries.length; i++) {
      try {
        final binary = binaries[i];
        final serverReleaseDate = await binary.checkReleaseDate();
        if (serverReleaseDate != null) {
          final updatedConfig = binary.download.copyWith(remoteTimestamp: serverReleaseDate);
          binaries[i] = binary.copyWith(download: updatedConfig);

          // Update state if installed
          if (_downloadStates[binary.name]?.status == DownloadStatus.installed) {
            _downloadStates[binary.name] = DownloadState(
              status: DownloadStatus.installed,
              message: 'Installed (${serverReleaseDate.toLocal()})',
            );
            _statusController.add(Map.from(_downloadStates));
          }
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
    Binary binary,
    DownloadStatus status, {
    double progress = 0.0,
    String? message,
    String? error,
  }) {
    _downloadStates[binary.name] = DownloadState(
      status: status,
      progress: progress,
      message: message,
      error: error,
    );
    _statusController.add(Map.from(_downloadStates));
  }

  // Start a binary, and set starter seeds (if set)
  Future<void> startBinary(BuildContext context, Binary binary, {bool useStarter = false}) async {
    if (!context.mounted) return;

    switch (binary) {
      case ParentChain():
        await mainchainRPC.initBinary(context);

      case Enforcer():
        await enforcerRPC.initBinary(context);

      case BitWindow():
        await bitwindowRPC.initBinary(context);

      case Thunder():
        await thunderRPC.initBinary(context);
        if (useStarter) {
          await _setStarterSeed(binary);
        }

      case Bitnames():
        await bitnamesRPC.initBinary(context);
        if (useStarter) {
          await _setStarterSeed(binary);
        }

      default:
        log.i('is $binary');
    }
    Future.delayed(const Duration(seconds: 3), () {
      // give it a bit of time to clean fucked up error messages
      _explicitlyLaunched[binary.name] = true;
    });

    notifyListeners();

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
      final releaseDate = await binary.downloadAndExtract(
        appDir,
        (status, {progress = 0.0, message, error}) {
          _updateStatus(
            binary,
            status,
            progress: progress,
            message: message,
            error: error,
          );
        },
      );

      // After successful download
      final updatedConfig = binary.download.copyWith(
        remoteTimestamp: releaseDate,
        downloadedTimestamp: releaseDate,
      );
      binary = binary.copyWith(download: updatedConfig);
    } finally {
      // Only clean up if this was the only active download
      if (_activeDownloads.values.where((active) => active).length == 1) {
        await _cleanUp(appDir);
      }
      // after 3 seconds, set the download state to false
      await Future.delayed(const Duration(seconds: 3));

      _activeDownloads[binary.name] = false;
    }
  }

  Future<void> _cleanUp(Directory datadir) async {
    final downloadsDir = Directory(path.join(datadir.path, 'assets', 'downloads'));
    await downloadsDir.delete(recursive: true);
  }

  /// Check if a binary can be started based on its dependencies
  bool canStart(Binary binary) {
    return switch (binary) {
      BitWindow() => mainchainConnected && enforcerConnected,
      Thunder() => mainchainConnected && enforcerConnected, // L2 binary
      Bitnames() => mainchainConnected && enforcerConnected,
      _ => true, // No dependencies for mainchain/enforcer
    };
  }

  /// Get dependency message if binary cannot be started
  String? getDependencyMessage(Binary binary) {
    return switch (binary) {
      BitWindow() when !mainchainConnected => 'Requires mainchain to be running first',
      Thunder() when !mainchainConnected => 'Requires mainchain to be running first',
      _ => null,
    };
  }

  Future<void> _setStarterSeed(Binary binary) async {
    if (binary is! Sidechain) return;

    try {
      final starterDir = path.join(appDir.path, 'wallet_starters');
      final starterFile = File(
        path.join(
          starterDir,
          'sidechain_${binary.slot}_starter.json',
        ),
      );

      if (!starterFile.existsSync()) return;

      final content = await starterFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final mnemonic = json['mnemonic'] as String?;

      if (mnemonic == null) return;

      switch (binary) {
        case Thunder():
          await thunderRPC.setSeedFromMnemonic(mnemonic);
        case Bitnames():
          await bitnamesRPC.setSeedFromMnemonic(mnemonic);
        default:
          break;
      }
    } catch (e) {
      log.e('Error setting starter seed: $e');
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
