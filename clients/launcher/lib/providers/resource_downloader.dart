import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:launcher/env.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';

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
  final String componentId;
  final DownloadStatus status;
  final double progress;
  final String? message;
  final String? error;

  DownloadProgress({
    required this.componentId,
    required this.status,
    this.progress = 0.0,
    this.message,
    this.error,
  });
}

/// Service responsible for downloading and managing binary resources
class ResourceDownloader {
  final Dio _dio = Dio();

  // Stream controller for progress updates
  final _progressController = StreamController<DownloadProgress>.broadcast();
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  /// Downloads and sets up a component
  Future<bool> downloadComponent(Binary component) async {
    final datadir = await Environment.datadir();
    final dir = path.join(datadir.path, 'assets');

    try {
      // Determine platform-specific details
      final platform = _getPlatformKey();
      final baseUrl = component.download.baseUrl;
      final fileName = component.download.files[platform]!;
      final downloadUrl = Uri.parse(baseUrl).resolve(fileName).toString();

      // Get the target directory from component config
      final targetDir = path.join(dir, component.directories.base[platform]!);

      // Create target directory if it doesn't exist
      await Directory(targetDir).create(recursive: true);

      // Start download
      _progressController.add(
        DownloadProgress(
          componentId: component.name,
          status: DownloadStatus.downloading,
          message: 'Starting download...',
        ),
      );

      final filePath = path.join(targetDir, fileName);
      await _downloadFile(downloadUrl, filePath, component.name);

      // Extract the downloaded file
      _progressController.add(
        DownloadProgress(
          componentId: component.name,
          status: DownloadStatus.extracting,
          message: 'Extracting files...',
        ),
      );

      await _extractFile(filePath, targetDir, fileName);

      // Verify binary exists and is executable
      _progressController.add(
        DownloadProgress(
          componentId: component.name,
          status: DownloadStatus.verifying,
          message: 'Verifying installation...',
        ),
      );

      final binaryPath = path.join(
        targetDir,
        component.binary,
      );

      if (!await verifyBinary(binaryPath)) {
        throw Exception('Binary verification failed');
      }

      // Cleanup downloaded archive
      await File(filePath).delete();

      _progressController.add(
        DownloadProgress(
          componentId: component.name,
          status: DownloadStatus.completed,
          progress: 1.0,
          message: 'Installation complete',
        ),
      );

      return true;
    } catch (e) {
      _progressController.add(
        DownloadProgress(
          componentId: component.name,
          status: DownloadStatus.failed,
          error: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Downloads a file with progress tracking
  Future<void> _downloadFile(
    String url,
    String savePath,
    String componentId,
  ) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _progressController.add(
              DownloadProgress(
                componentId: componentId,
                status: DownloadStatus.downloading,
                progress: progress,
                message: 'Downloaded ${(progress * 100).toStringAsFixed(1)}%',
              ),
            );
          }
        },
      );
    } catch (e) {
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  /// Extracts downloaded archive
  Future<void> _extractFile(
    String archivePath,
    String targetDir,
    String fileName,
  ) async {
    final file = File(archivePath);
    final bytes = await file.readAsBytes();

    Archive archive;
    if (fileName.endsWith('.zip')) {
      archive = ZipDecoder().decodeBytes(bytes);
    } else if (fileName.endsWith('.tar.gz')) {
      final gzBytes = GZipDecoder().decodeBytes(bytes);
      archive = TarDecoder().decodeBytes(gzBytes);
    } else {
      throw Exception('Unsupported archive format');
    }

    for (final file in archive) {
      final filePath = path.join(targetDir, file.name);
      if (file.isFile) {
        final data = file.content as List<int>;
        await File(filePath).create(recursive: true);
        await File(filePath).writeAsBytes(data);

        // Make binary files executable
        if (!Platform.isWindows && !file.name.contains('.')) {
          await Process.run(
            'chmod',
            ['+x', filePath],
          );
        }
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }
  }

  /// Verifies that the binary exists and is executable
  Future<bool> verifyBinary(String binaryPath) async {
    final file = File(binaryPath);
    if (!await file.exists()) {
      return false;
    }

    if (!Platform.isWindows) {
      // Check if file is executable on Unix systems
      final stat = await file.stat();
      return (stat.mode & 0x49) != 0; // Check for executable bit
    }

    return true;
  }

  /// Gets the platform-specific key used in config
  OS _getPlatformKey() {
    if (Platform.isWindows) {
      return OS.windows;
    }
    if (Platform.isMacOS) {
      return OS.macos;
    }
    if (Platform.isLinux) {
      return OS.linux;
    }
    throw Exception('Unsupported platform');
  }

  /// Disposes of resources
  void dispose() {
    _progressController.close();
  }
}
