import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/chains.dart';
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
  final Directory datadir;
  late List<Binary> binaries;

  // Track download status for each binary
  final _downloadStates = <String, DownloadState>{};

  // Stream controller for status updates
  final _statusController = StreamController<Map<String, DownloadState>>.broadcast();
  Stream<Map<String, DownloadState>> get statusStream => _statusController.stream;

  // Track RPC connections
  MainchainRPC? mainchainRPC;
  EnforcerRPC? enforcerRPC;
  BitwindowRPC? bitwindowRPC;
  ThunderRPC? thunderRPC;
  // TODO: Add Thunder RPC when available

  // Connection status getters
  bool get mainchainConnected => mainchainRPC?.connected ?? false;
  bool get enforcerConnected => enforcerRPC?.connected ?? false;
  bool get bitwindowConnected => bitwindowRPC?.connected ?? false;

  bool get mainchainInitializing => mainchainRPC?.initializingBinary ?? false;
  bool get enforcerInitializing => enforcerRPC?.initializingBinary ?? false;
  bool get bitwindowInitializing => bitwindowRPC?.initializingBinary ?? false;

  String? get mainchainError => mainchainRPC?.connectionError;
  String? get enforcerError => enforcerRPC?.connectionError;
  String? get bitwindowError => bitwindowRPC?.connectionError;

  bool get inIBD => mainchainRPC?.inIBD ?? false;

  BinaryProvider({
    required this.datadir,
    required List<Binary> initialBinaries,
  }) {
    binaries = initialBinaries;
    initialize();
    // Add listeners to notify UI of status changes
    mainchainRPC?.addListener(notifyListeners);
    enforcerRPC?.addListener(notifyListeners);
    bitwindowRPC?.addListener(notifyListeners);
  }

  /// Initialize download states for all binaries
  Future<void> initialize() async {
    _log('Read binaries from assets/chain_config.json: Found ${binaries.length} binaries');

    for (var i = 0; i < binaries.length; i++) {
      final binary = binaries[i];
      try {
        _log('Checking binary: ${binary.name} (${binary.binary})');
        _log('datadir is: ${datadir.path}');

        // Check release date from server
        final serverReleaseDate = await binary.checkReleaseDate();
        if (serverReleaseDate != null) {
          // Update the binary in the config provider's list
          final updatedConfig = binary.download.copyWith(remoteTimestamp: serverReleaseDate);
          binaries[i] = binary.copyWith(download: updatedConfig);
        }

        // Check if binary exists in assets/
        final exists = await binary.exists(datadir);
        _log('${binary.name} exists: $exists');

        if (!exists) {
          _downloadStates[binary.name] = DownloadState(
            status: DownloadStatus.uninstalled,
          );
          continue;
        }

        // Load metadata from assets/
        final metadata = await binary.loadMetadata(datadir);
        _log('${binary.name} metadata: ${metadata != null}');

        _downloadStates[binary.name] = DownloadState(
          status: DownloadStatus.installed,
          message: metadata != null ? 'Installed (${metadata.releaseDate.toLocal()})' : 'Installed (unverified)',
        );
      } catch (e) {
        _log('Error initializing state for ${binary.name}: $e');
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

  void _log(String message) {
    log.i('BinaryProvider: $message');
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

  Future<void> startBinary(BuildContext context, Binary binary) async {
    if (!context.mounted) return;

    switch (binary) {
      case ParentChain():
        if (mainchainRPC == null) {
          mainchainRPC = await MainchainRPCLive.create(
            binary,
          );
          mainchainRPC!.addListener(notifyListeners);
        }
        if (!context.mounted) return;
        await mainchainRPC!.initBinary(context);

      case Enforcer():
        if (enforcerRPC == null) {
          enforcerRPC = await EnforcerLive.create(
            binary: binary,
            logPath: path.join(datadir.path, 'enforcer.log'),
          );
          enforcerRPC!.addListener(notifyListeners);
        }
        if (!context.mounted) return;
        await enforcerRPC!.initBinary(context);

      case BitWindow():
        if (bitwindowRPC == null) {
          bitwindowRPC = await BitwindowRPCLive.create(
            host: 'localhost',
            port: binary.port,
            binary: binary,
            logPath: path.join(datadir.path, 'bitwindow.log'),
          );
          bitwindowRPC!.addListener(notifyListeners);
        }
        if (!context.mounted) return;
        await bitwindowRPC!.initBinary(context);

      case Thunder():
        if (thunderRPC == null) {
          thunderRPC = await ThunderLive.create(
            binary: binary,
            logPath: path.join(datadir.path, 'thunder.log'),
          );
          thunderRPC!.addListener(notifyListeners);
        }
        if (!context.mounted) return;
        await thunderRPC!.initBinary(context);

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
      _ => false,
    };
  }

  Future<void> downloadBinary(Binary binary) async {
    final releaseDate = await binary.downloadAndExtract(
      datadir,
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
      downloadedTimestamp: DateTime.now(),
    );
    binary = binary.copyWith(download: updatedConfig);
  }

  @override
  void dispose() {
    mainchainRPC?.removeListener(notifyListeners);
    mainchainRPC?.dispose();
    enforcerRPC?.removeListener(notifyListeners);
    enforcerRPC?.dispose();
    bitwindowRPC?.removeListener(notifyListeners);
    bitwindowRPC?.dispose();
    super.dispose();
  }
}
