import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/utils/file_utils.dart';

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

  /// Update status for a binary
  Future<void> _updateStatus(
    Binary binary,
    DownloadStatus status, {
    double progress = 0.0,
    String? message,
    String? error,
  }) async {
    _downloadStates[binary.name] = DownloadState(
      status: status,
      progress: progress,
      message: message,
      error: error,
    );
    _statusController.add(Map.from(_downloadStates));
  }

  /// Downloads and installs a binary
  Future<void> downloadBinary(Binary binary) async {
    try {
      await _updateStatus(
        binary,
        DownloadStatus.installing,
        message: 'Starting download...',
      );

      final os = getOS();
      final fileName = binary.download.files[os]!;
      final downloadUrl = Uri.parse(binary.download.baseUrl).resolve(fileName).toString();

      // 1. Setup paths
      final downloadsDir = path.join(datadir.path, 'assets', 'downloads');
      final extractedDir = path.join(downloadsDir, 'extracted');
      final zipPath = path.join(downloadsDir, fileName);

      _log('Downloads dir: $downloadsDir');
      _log('Extracted dir: $extractedDir');
      _log('Zip path: $zipPath');

      // Create all required directories recursively
      await Directory(path.dirname(zipPath)).create(recursive: true);
      await Directory(extractedDir).create(recursive: true);

      await _updateStatus(
        binary,
        DownloadStatus.installing,
        message: 'Downloading...',
      );
      final releaseDate = await _downloadBinary(downloadUrl, zipPath, binary);

      // 3. Extract
      await _updateStatus(
        binary,
        DownloadStatus.installing,
        message: 'Extracting archive...',
      );

      final inputStream = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeBuffer(inputStream);
      await extractArchiveToDisk(archive, extractedDir);

      // 4. Move binary to final location
      await _updateStatus(
        binary,
        DownloadStatus.installing,
        message: 'Installing binary...',
      );

      // Find the binary in the extracted folder
      final binaryName = path.basename(binary.binary);
      _log('Looking for binary name: $binaryName');

      // Find any binary in the extracted folder
      final binaryFile = await _findBinary(extractedDir, binaryName);
      if (binaryFile == null) {
        throw Exception('No binary found in extracted files');
      }

      // Move and rename binary to assets/
      final finalBinaryPath = path.join(datadir.path, 'assets', binary.binary);
      _log('Moving binary from ${binaryFile.path} to $finalBinaryPath');

      // Create assets directory if it doesn't exist
      await Directory(path.dirname(finalBinaryPath)).create(recursive: true);

      // Copy the binary first
      await binaryFile.copy(finalBinaryPath);

      // Verify the copy was successful
      if (!await File(finalBinaryPath).exists()) {
        throw Exception('Failed to copy binary to final location');
      }

      // After successful move, save hash and release date
      final hash = await binary.calculateHash(datadir);
      if (hash == null) {
        throw Exception('Could not calculate hash for downloaded binary');
      }

      await binary.saveMetadata(
        datadir,
        DownloadMetadata(
          hash: hash,
          releaseDate: releaseDate,
        ),
      );

      // Update status to completed
      await _updateStatus(
        binary,
        DownloadStatus.installed,
        message: 'Installed (${DateTime.now().toLocal()})',
      );

      // Only clean up downloads after everything else succeeded
      await _cleanup(downloadsDir);
    } catch (e) {
      await _updateStatus(
        binary,
        DownloadStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Clean up the downloads directory
  Future<void> _cleanup(String downloadsDir) async {
    try {
      final dir = Directory(downloadsDir);
      if (await dir.exists()) {
        _log('Cleaning up downloads directory: $downloadsDir');
        await dir.delete(recursive: true);
        _log('Successfully cleaned up downloads directory');
      }
    } catch (e) {
      // Log but don't throw - cleanup failure shouldn't fail the installation
      _log('Warning: Failed to clean up downloads directory: $e');
    }
  }

  /// Find a binary file recursively in a directory
  Future<File?> _findBinary(String directory, String binaryName) async {
    final dir = Directory(directory);
    _log('Looking for binary in $directory');

    // List all files recursively and log them for debugging
    await for (final entity in dir.list(recursive: true)) {
      _log('Found file: ${entity.path}');
      // Take the first executable file we find
      if (entity is File) {
        // TODO: On Windows/Mac we might want to check file permissions
        _log('Found binary at ${entity.path}');
        return entity;
      }
    }

    _log('No binary found in extracted files');
    return null;
  }

  void _log(String message) {
    log.i('DownloadProvider: $message');
  }

  /// Downloads a file with progress tracking
  /// Returns the release date from the Last-Modified header
  Future<DateTime> _downloadBinary(String url, String savePath, Binary binary) async {
    try {
      final client = HttpClient();
      _log('Starting download for ${binary.name} from $url to $savePath');

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP Status ${response.statusCode}');
      }

      // Get the Last-Modified date from headers
      final lastModified = response.headers.value('last-modified');
      if (lastModified == null) {
        throw Exception('Server did not provide Last-Modified header');
      }
      final releaseDate = HttpDate.parse(lastModified);
      _log('Binary release date: $releaseDate');

      final file = File(savePath);
      final sink = file.openWrite();

      final totalBytes = response.contentLength;
      var receivedBytes = 0;

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes != -1) {
          final progress = receivedBytes / totalBytes;
          final downloadedMB = (receivedBytes / 1024 / 1024).toStringAsFixed(1);
          final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(1);

          if (receivedBytes % (5 * 1024 * 1024) == 0) {
            // Log every 5MB
            _log('${binary.name}: Downloaded $downloadedMB MB / $totalMB MB (${(progress * 100).toStringAsFixed(1)}%)');
          }

          await _updateStatus(
            binary,
            DownloadStatus.installing,
            progress: progress,
            message: 'Downloading... $downloadedMB MB / $totalMB MB (${(progress * 100).toStringAsFixed(1)}%)',
          );
        }
      }

      await sink.close();
      client.close();

      _log('Download completed for ${binary.name}');

      // Update status for next phase
      await _updateStatus(
        binary,
        DownloadStatus.installing,
        message: 'Verifying download...',
      );

      return releaseDate; // Return the release date
    } catch (e) {
      final error = 'Download failed from $url: $e\nSave path: $savePath';
      _log('ERROR: $error');
      throw Exception(error);
    }
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
