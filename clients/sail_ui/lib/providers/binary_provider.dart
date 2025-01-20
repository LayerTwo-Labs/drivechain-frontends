import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
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

  // Track download status and active downloads for each binary
  final _downloadStates = <String, DownloadState>{};
  final _activeDownloads = <String, bool>{}; // Track per-binary downloads

  // Stream controller for status updates
  final _statusController = StreamController<Map<String, DownloadState>>.broadcast();
  Stream<Map<String, DownloadState>> get statusStream => _statusController.stream;

  // Track RPC connections
  MainchainRPC? mainchainRPC;
  EnforcerRPC? enforcerRPC;
  BitwindowRPC? bitwindowRPC;
  ThunderRPC? thunderRPC;
  BitnamesRPC? bitnamesRPC;

  // Connection status getters
  bool get mainchainConnected => mainchainRPC?.connected ?? false;
  bool get enforcerConnected => enforcerRPC?.connected ?? false;
  bool get bitwindowConnected => bitwindowRPC?.connected ?? false;
  bool get thunderConnected => thunderRPC?.connected ?? false;
  bool get bitnamesConnected => bitnamesRPC?.connected ?? false;
  bool get mainchainInitializing => mainchainRPC?.initializingBinary ?? false;
  bool get enforcerInitializing => enforcerRPC?.initializingBinary ?? false;
  bool get bitwindowInitializing => bitwindowRPC?.initializingBinary ?? false;
  bool get thunderInitializing => thunderRPC?.initializingBinary ?? false;
  bool get bitnamesInitializing => bitnamesRPC?.initializingBinary ?? false;
  // Add a flag to track if binaries were explicitly launched
  final Map<String, bool> _explicitlyLaunched = {};

  // Only show errors for explicitly launched binaries
  String? get mainchainError => _explicitlyLaunched[ParentChain().name] == true ? mainchainRPC?.connectionError : null;
  String? get enforcerError => _explicitlyLaunched[Enforcer().name] == true ? enforcerRPC?.connectionError : null;
  String? get bitwindowError => _explicitlyLaunched[BitWindow().name] == true ? bitwindowRPC?.connectionError : null;
  String? get thunderError => _explicitlyLaunched[Thunder().name] == true ? thunderRPC?.connectionError : null;
  String? get bitnamesError => _explicitlyLaunched[Bitnames().name] == true ? bitnamesRPC?.connectionError : null;

  bool get inIBD => mainchainRPC?.inIBD ?? false;

  BinaryProvider({
    required this.appDir,
    required List<Binary> initialBinaries,
  }) {
    binaries = initialBinaries;
    initialize();
    _setupDirectoryWatcher();
    // Add listeners to notify UI of status changes
    mainchainRPC?.addListener(notifyListeners);
    enforcerRPC?.addListener(notifyListeners);
    bitwindowRPC?.addListener(notifyListeners);
    thunderRPC?.addListener(notifyListeners);
    bitnamesRPC?.addListener(notifyListeners);
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
    for (var i = 0; i < binaries.length; i++) {
      final binary = binaries[i];
      try {
        await initRPC(binary);

        // Check release date from server
        final serverReleaseDate = await binary.checkReleaseDate();
        var updatedConfig = binary.download;
        if (serverReleaseDate != null) {
          updatedConfig = updatedConfig.copyWith(remoteTimestamp: serverReleaseDate);
        }

        // Check if binary exists in assets/
        final exists = await binary.exists(appDir);

        if (!exists) {
          _downloadStates[binary.name] = DownloadState(
            status: DownloadStatus.uninstalled,
          );
          continue;
        }

        // Load metadata from assets/
        final metadata = await binary.loadMetadata(appDir);

        if (metadata != null) {
          // Update the binary's download config with the downloaded timestamp
          updatedConfig = updatedConfig.copyWith(downloadedTimestamp: metadata.releaseDate);
        }

        // Update binary with all timestamp info
        binaries[i] = binary.copyWith(download: updatedConfig);

        _downloadStates[binary.name] = DownloadState(
          status: DownloadStatus.installed,
          message: metadata != null ? 'Installed (${metadata.releaseDate?.toLocal()})' : 'Installed (unverified)',
        );
      } catch (e) {
        _downloadStates[binary.name] = DownloadState(
          status: DownloadStatus.failed,
          error: 'Could not determine binary status: $e',
        );
      }
    }

    // Emit initial states
    _statusController.add(Map.from(_downloadStates));
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

  // Mark binary as explicitly launched when started
  Future<void> startBinary(BuildContext context, Binary binary) async {
    if (!context.mounted) return;

    _explicitlyLaunched[binary.name] = true;
    await initRPC(binary);

    switch (binary) {
      case ParentChain():
        await mainchainRPC!.initBinary(context);

      case Enforcer():
        await enforcerRPC!.initBinary(context);

      case BitWindow():
        await bitwindowRPC!.initBinary(context);

      case Thunder():
        await thunderRPC!.initBinary(context);

      case Bitnames():
        await bitnamesRPC!.initBinary(context);

      default:
        log.i('is $binary');
    }
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

  Future<void> initRPC(Binary binary) async {
    switch (binary) {
      case ParentChain():
        if (mainchainRPC == null) {
          mainchainRPC = await MainchainRPCLive.create(binary);
          mainchainRPC!.addListener(notifyListeners);
        }

      case Enforcer():
        if (enforcerRPC == null) {
          enforcerRPC = await EnforcerLive.create(
            binary: binary,
            logPath: path.join(binary.datadir(), 'enforcer.log'),
          );
          enforcerRPC!.addListener(notifyListeners);
        }

      case BitWindow():
        if (bitwindowRPC == null) {
          bitwindowRPC = await BitwindowRPCLive.create(
            host: 'localhost',
            port: binary.port,
            binary: binary,
            logPath: path.join(binary.datadir(), 'bitwindow.log'),
          );
          bitwindowRPC!.addListener(notifyListeners);
        }

      case Thunder():
        if (thunderRPC == null) {
          thunderRPC = await ThunderLive.create(
            binary: binary,
            logPath: path.join(binary.datadir(), 'thunder.log'),
          );
          thunderRPC!.addListener(notifyListeners);
        }

      case Bitnames():
        if (bitnamesRPC == null) {
          bitnamesRPC = await BitnamesLive.create(
            binary: binary,
            logPath: path.join(binary.datadir(), 'bitnames.log'),
          );
          bitnamesRPC!.addListener(notifyListeners);
        }

      default:
        log.i('is $binary');
    }
  }

  @override
  void dispose() {
    _dirWatcher?.cancel();
    mainchainRPC?.removeListener(notifyListeners);
    mainchainRPC?.dispose();
    enforcerRPC?.removeListener(notifyListeners);
    enforcerRPC?.dispose();
    bitwindowRPC?.removeListener(notifyListeners);
    bitwindowRPC?.dispose();
    thunderRPC?.removeListener(notifyListeners);
    thunderRPC?.dispose();
    bitnamesRPC?.removeListener(notifyListeners);
    bitnamesRPC?.dispose();
    super.dispose();
  }
}
