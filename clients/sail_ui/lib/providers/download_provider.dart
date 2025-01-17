import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/utils/file_utils.dart';

/// Manages downloads and installations of binaries
class DownloadProvider {
  final Directory datadir;
  final List<Binary> binaries;

  // Stream controller for download status
  final _statusController = StreamController<Map<String, DownloadProgress>>.broadcast();
  Stream<Map<String, DownloadProgress>> get statusStream => _statusController.stream;

  // Track status of all binaries
  final Map<String, DownloadProgress> _binaryStatus = {};

  DownloadProvider({
    required this.datadir,
    required this.binaries,
  }) {
    // Initialize all binaries with "not started" status
    for (final binary in binaries) {
      _binaryStatus[binary.name] = DownloadProgress(
        binaryName: binary.name,
        status: DownloadStatus.notStarted,
      );
    }
    _emitStatus();
  }

  /// Download all required binaries
  Future<bool> downloadAllBinaries() async {
    bool success = true;

    // Download L1 components first
    final l1Chains = binaries.where((binary) => binary.chainLayer == 1);
    for (final chain in l1Chains) {
      if (!await downloadBinary(chain)) {
        success = false;
        break;
      }
    }

    // Then download L2 components if L1 was successful
    if (success) {
      final l2Chains = binaries.where((binary) => binary.chainLayer == 2);
      for (final chain in l2Chains) {
        if (!await downloadBinary(chain)) {
          success = false;
          break;
        }
      }
    }

    return success;
  }

  /// Downloads and sets up a binary
  Future<bool> downloadBinary(Binary binary) async {
    try {
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

      // 2. Download
      await Directory(downloadsDir).create(recursive: true);
      await Directory(extractedDir).create(recursive: true);

      _updateStatus(binary.name, DownloadStatus.downloading);
      await _downloadFile(downloadUrl, zipPath, binary.name);

      // 3. Extract
      _updateStatus(
        binary.name,
        DownloadStatus.extracting,
        message: 'Extracting archive...',
      );

      final inputStream = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeBuffer(inputStream);
      await extractArchiveToDisk(archive, extractedDir);

      // 4. Move binary to final location
      _updateStatus(
        binary.name,
        DownloadStatus.verifying,
        message: 'Installing binary...',
      );

      // Find the binary in the extracted folder
      final binaryName = path.basename(binary.binary);
      _log('Looking for binary name: $binaryName');

      // The final destination is directly in assets/
      final finalBinaryPath = path.join(datadir.path, 'assets', binaryName);
      _log('Final binary path: $finalBinaryPath');

      final binaryFile = await _findBinary(extractedDir, binaryName);
      if (binaryFile == null) {
        throw Exception('Binary $binaryName not found in extracted files');
      }

      // Move binary directly to assets/
      _log('Moving binary from ${binaryFile.path} to $finalBinaryPath');
      await binaryFile.copy(finalBinaryPath);

      _updateStatus(
        binary.name,
        DownloadStatus.completed,
        progress: 1.0,
        message: 'Installation complete',
      );

      return true;
    } catch (e) {
      _updateStatus(
        binary.name,
        DownloadStatus.failed,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Find a binary file recursively in a directory
  Future<File?> _findBinary(String directory, String binaryName) async {
    final dir = Directory(directory);
    _log('Looking for binary $binaryName in $directory');

    // List all files recursively and log them for debugging
    await for (final entity in dir.list(recursive: true)) {
      _log('Found file: ${entity.path}');
      if (entity is File && path.basename(entity.path) == binaryName) {
        _log('Found binary at ${entity.path}');
        return entity;
      }
    }

    _log('Binary not found in extracted files');
    return null;
  }

  void _log(String message) {
    print('[DownloadProvider] $message');
  }

  /// Downloads a file with progress tracking
  Future<void> _downloadFile(String url, String savePath, String binaryName) async {
    try {
      final client = HttpClient();
      _log('Starting download for $binaryName');
      _log('URL: $url');
      _log('Save path: $savePath');

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP Status ${response.statusCode}');
      }

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
            _log('$binaryName: Downloaded $downloadedMB MB / $totalMB MB (${(progress * 100).toStringAsFixed(1)}%)');
          }

          _updateStatus(
            binaryName,
            DownloadStatus.downloading,
            progress: progress,
            message: 'Downloading... $downloadedMB MB / $totalMB MB (${(progress * 100).toStringAsFixed(1)}%)',
          );
        }
      }

      await sink.close();
      client.close();

      _log('Download completed for $binaryName');
    } catch (e) {
      final error = 'Download failed from $url: $e\nSave path: $savePath';
      _log('ERROR: $error');
      throw Exception(error);
    }
  }

  /// Update status for a binary
  void _updateStatus(
    String binaryName,
    DownloadStatus status, {
    double progress = 0.0,
    String? message,
    String? error,
  }) {
    _binaryStatus[binaryName] = DownloadProgress(
      binaryName: binaryName,
      status: status,
      progress: progress,
      message: message,
      error: error,
    );
    _emitStatus();
  }

  /// Emit current status to listeners
  void _emitStatus() {
    _statusController.add(Map.from(_binaryStatus));
  }

  /// Get current status for a binary
  DownloadProgress? getBinaryStatus(String binaryName) {
    return _binaryStatus[binaryName];
  }

  /// Get current status for all binaries
  Map<String, DownloadProgress> getAllBinaryStatus() {
    return Map.from(_binaryStatus);
  }

  /// Dispose of resources
  void dispose() {
    _statusController.close();
  }
}

/// Represents the current status of a download operation
enum DownloadStatus {
  notStarted,
  downloading,
  extracting,
  verifying,
  completed,
  failed,
}

/// Represents a download progress update
class DownloadProgress {
  final String binaryName;
  final DownloadStatus status;
  final double progress;
  final String? message;
  final String? error;

  DownloadProgress({
    required this.binaryName,
    required this.status,
    this.progress = 0.0,
    this.message,
    this.error,
  });
}
