import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

/// Manager responsible for downloading and extracting binaries to
/// the right place
class DownloadManager extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;
  late List<Binary> binaries;

  // Private constructor
  DownloadManager._create({
    required this.appDir,
    required this.binaries,
  });

  // Async factory
  static Future<DownloadManager> create({
    required Directory appDir,
    required List<Binary> initialBinaries,
  }) async {
    final binariesWithTimestamps = await loadBinaryCreationTimestamp(initialBinaries, appDir);

    return DownloadManager._create(
      appDir: appDir,
      binaries: binariesWithTimestamps,
    );
  }

  // Test constructor (visible for mocking)
  @visibleForTesting
  DownloadManager.test({
    required this.appDir,
    required this.binaries,
  });

  DownloadInfo getProgress(BinaryType type) {
    final binary = binaries.firstWhere((b) => b.type == type);
    return binary.downloadInfo;
  }

  Future<void> downloadIfMissing(Binary binary, {bool shouldUpdate = false}) async {
    if (binary.updateAvailable) {
      if (shouldUpdate) {
        // We have an available update, and the binary we use is in
        // appDir/assets/bin, so we go ahead and update it
        return await _downloadBinary(binary);
      } else {
        log.w('binary ${binary.name} is not updateable');
      }
    }

    if (binary.isDownloaded) {
      // We already have a binary, dont bother
      return;
    }

    await _downloadBinary(binary);
  }

  /// Download and extract a binary
  Future<void> _downloadBinary(Binary binary) async {
    // Check if already downloading
    if (isDownloading(binary.type)) {
      log.i('Download already in progress for ${binary.name}, waiting for completion...');
      // Wait for the download to complete
      while (isDownloading(binary.type)) {
        await Future.delayed(const Duration(milliseconds: 100));
        log.i('download already in progress for ${binary.name}, waiting for it to finish...');
      }
      return;
    }

    try {
      await _downloadAndExtractBinary(binary);
    } catch (e) {
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(
            progress: 0.0,
            error: 'Download failed: $e',
            isDownloading: false,
          ),
        ),
      );
      log.e('could not download ${binary.name}: $e');
      rethrow;
    }
  }

  void _updateBinary(String name, Binary Function(Binary) updater) {
    final index = binaries.indexWhere((b) => b.name == name);
    if (index >= 0) {
      final newBinary = updater(binaries[index]);
      binaries[index] = newBinary;
      notifyListeners();
    }
  }

  bool isDownloading(BinaryType type) {
    return binaries.any((b) => b.type == type && b.downloadInfo.isDownloading);
  }

  /// Internal method to handle the actual download and extraction
  Future<void> _downloadAndExtractBinary(Binary binary) async {
    if (binary.metadata.baseUrl.isEmpty) {
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: const DownloadInfo(
            progress: 0.0,
            total: 0.0,
            message: 'Programmers messed up. Tried to download non-downloadable binary',
            isDownloading: false,
          ),
        ),
      );
      return;
    }

    _updateBinary(
      binary.name,
      (b) => b.copyWith(
        downloadInfo: const DownloadInfo(
          progress: 0.0,
          message: 'Downloading...',
          isDownloading: true,
        ),
      ),
    );

    // 1. Setup directories
    final downloadsDir = Directory(path.join(appDir.path, 'downloads'));
    final extractDir = binDir(appDir.path);
    await downloadsDir.create(recursive: true);
    await extractDir.create(recursive: true);

    // Check if platform is supported
    final fileName = binary.metadata.files[OS.current];
    if (fileName == null || fileName.isEmpty) {
      log.w('No download file found for ${binary.name} on ${OS.current}');
      return;
    }

    String filePath;
    try {
      if (binary.metadata.baseUrl.contains('github.com')) {
        filePath = await _downloadGithubBinary(binary, downloadsDir);
      } else if (binary.metadata.baseUrl.contains('releases.drivechain.info')) {
        filePath = await _downloadReleasesBinary(binary, downloadsDir);
      } else {
        _updateBinary(
          binary.name,
          (b) => b.copyWith(
            downloadInfo: b.downloadInfo.copyWith(
              progress: 0.0,
              message: 'Programmers messed up. Did not find download strategy for ${binary.metadata.baseUrl}',
              isDownloading: false,
            ),
          ),
        );
        return;
      }

      // Extract the binary
      await _extractBinary(extractDir, filePath, downloadsDir, binary);
    } catch (e) {
      // Update binary state to show error
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(
            progress: 0.0,
            error: 'Extraction failed: $e',
            isDownloading: false,
          ),
        ),
      );
      rethrow;
    }

    try {
      // Try to clean up (fine if we fail!)
      await File(filePath).delete();
    } catch (e) {
      log.e('could not delete zip file: $e');
    }

    // Update binary metadata
    // find the updated binary
    final updatedBinary = await binary.updateMetadata(appDir);
    log.d('🔄 _updateBinary called from _downloadAndExtractBinary (update metadata) for ${binary.name}');

    _updateBinary(
      binary.name,
      (b) => b.copyWith(
        downloadInfo: DownloadInfo(
          message: 'Downloaded and extracted successfully',
          isDownloading: false,
          downloadedAt: DateTime.now(),
          progress: 1.0,
          total: 1.0,
        ),
        metadata: updatedBinary.metadata,
      ),
    );
    notifyListeners();

    log.i('Successfully downloaded and extracted ${binary.name}');
  }

  Future<String> _downloadGithubBinary(Binary binary, Directory downloadsDir) async {
    // For GitHub-based releases, download binary directly from releases
    final response = await http.get(Uri.parse(binary.metadata.baseUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch GitHub release: ${response.statusCode}');
    }

    // Use the regex pattern from binary configuration
    final regexPattern = binary.metadata.files[OS.current]!;
    final platformRegex = RegExp(regexPattern, caseSensitive: false);

    final assets = json.decode(response.body)['assets'] as List;
    // search for corresponding asset matching the metadata.files regex-pattern
    final asset = assets.firstWhere(
      (a) => platformRegex.hasMatch(a['name'].toString()),
      orElse: () => throw Exception('No matching asset found for platform: ${OS.current}'),
    );

    // Download the binary using the actual asset name
    final downloadUrl = asset['browser_download_url'];
    final fileName = asset['name'].toString();
    final filePath = path.join(downloadsDir.path, fileName);

    try {
      await _downloadFile(downloadUrl, filePath, binary.name);
      return filePath;
    } catch (e) {
      // Clean up partial download if it exists
      try {
        final partialFile = File(filePath);
        if (await partialFile.exists()) {
          await partialFile.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
      rethrow;
    }
  }

  Future<String> _downloadReleasesBinary(Binary binary, Directory downloadsDir) async {
    // 2. Download the binary
    final zipName = binary.metadata.files[OS.current]!;
    final zipPath = path.join(downloadsDir.path, zipName);
    final downloadUrl = Uri.parse(binary.metadata.baseUrl).resolve(zipName).toString();
    await _downloadFile(downloadUrl, zipPath, binary.name);
    return zipPath;
  }

  /// Download a file
  Future<void> _downloadFile(String url, String savePath, String binaryName) async {
    log.i('_downloadFile started for $binaryName from $url');
    try {
      final client = HttpClient();
      log.i('Starting download from $url to $savePath');

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP Status ${response.statusCode}');
      }

      final file = File(savePath);
      final sink = file.openWrite();

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      String lastPercentStr = '';

      log.i('Download starting: totalBytes=$totalBytes, binaryName=$binaryName');

      double downloadedMB = 0;
      double totalMB = 0;

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes != -1) {
          final progress = receivedBytes / totalBytes;
          final currentPercentStr = (progress * 100).toStringAsFixed(1);

          // Only update if the percentage display would change
          if (currentPercentStr != lastPercentStr) {
            downloadedMB = receivedBytes / 1024 / 1024;
            totalMB = totalBytes / 1024 / 1024;

            _updateBinary(
              binaryName,
              (b) => b.copyWith(
                downloadInfo: DownloadInfo(
                  progress: downloadedMB,
                  total: totalMB,
                  message: 'Downloaded $downloadedMB MB / $totalMB MB ($currentPercentStr%)',
                  isDownloading: true,
                ),
              ),
            );

            lastPercentStr = currentPercentStr;
          }
        }
      }

      await sink.close();
      client.close();

      _updateBinary(
        binaryName,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(
            progress: totalMB,
            total: totalMB,
            message: 'Downloaded complete',
            isDownloading: true, // still downloading, because we need to extract it as well
          ),
        ),
      );
      log.i('Download completed for $binaryName');
    } catch (e) {
      final error = 'Download failed from $url: $e\nSave path: $savePath';
      log.e('ERROR: $error');
      _updateBinary(
        binaryName,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(
            progress: 0.0,
            message: error,
            isDownloading: false,
          ),
        ),
      );
      rethrow;
    }
  }

  /// Extract binary archive or process raw binary
  Future<void> _extractBinary(
    Directory extractDir,
    String filePath,
    Directory downloadsDir,
    Binary binary,
  ) async {
    _updateBinary(
      binary.name,
      (b) => b.copyWith(
        downloadInfo: DownloadInfo(
          progress: 0.9999,
          total: 1.0,
          isDownloading: true,
          message: 'Extracting...',
        ),
      ),
    );

    final fileName = path.basename(filePath);

    if (fileName.endsWith('.zip')) {
      // extract the zip file
      await _extractZipFile(extractDir, filePath, downloadsDir, binary);
    } else {
      // move the raw binary
      await _processRawBinary(extractDir, filePath, binary);
    }

    // Apply rename logic
    await _applyRenameLogic(extractDir);
  }

  /// Extract zip file (existing logic)
  Future<void> _extractZipFile(
    Directory extractDir,
    String zipPath,
    Directory downloadsDir,
    Binary binary,
  ) async {
    // Create a temporary directory for extraction
    final tempDir = Directory(path.join(extractDir.path, 'temp', path.basenameWithoutExtension(binary.binary)));
    try {
      await tempDir.delete(recursive: true);
    } catch (e) {
      // directory probably doesn't exist, swallow!
    }
    await tempDir.create(recursive: true);

    final inputStream = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeStream(inputStream);

    try {
      await extractArchiveToDisk(archive, tempDir.path);

      log.d('Moving files from temp directory to final location');
      await for (final entity in tempDir.list()) {
        final baseName = path.basename(entity.path);
        final targetPath = path.join(extractDir.path, baseName);

        if (entity is Directory && baseName == path.basenameWithoutExtension(zipPath)) {
          await for (final innerEntity in entity.list()) {
            await safeMove(innerEntity, path.join(extractDir.path, path.basename(innerEntity.path)));
          }
          await entity.delete(recursive: true);
          continue;
        }

        await safeMove(entity, targetPath);
      }

      // Clean up temp directory
      await tempDir.delete(recursive: true);

      // Get the zip name without extension
      final zipBaseName = path.basenameWithoutExtension(zipPath);
      final expectedDirPath = path.join(extractDir.path, zipBaseName);

      if (await Directory(expectedDirPath).exists()) {
        final innerDir = Directory(expectedDirPath);

        for (final entity in innerDir.listSync()) {
          final newPath = path.join(extractDir.path, path.basename(entity.path));
          await safeMove(entity, newPath);
        }
        await innerDir.delete(recursive: true);
      }
    } catch (e) {
      log.e('Extraction error: $e\nStack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Process raw binary file
  Future<void> _processRawBinary(
    Directory extractDir,
    String binaryPath,
    Binary binary,
  ) async {
    final downloadedFile = File(binaryPath);
    final fileName = path.basename(binaryPath);

    // Copy to extract directory
    final finalPath = path.join(extractDir.path, fileName);
    await downloadedFile.copy(finalPath);
    await downloadedFile.delete();
  }

  /// Apply rename logic to all files in extract directory
  Future<void> _applyRenameLogic(Directory extractDir) async {
    // Clean up the filename: remove version numbers and platform specifics
    await for (final entity in extractDir.list(recursive: false)) {
      if (entity is File) {
        final fileName = path.basename(entity.path);

        // Skip non-executable files
        if (fileName.endsWith('.zip') || fileName.endsWith('.meta') || fileName.endsWith('.md')) continue;

        String targetName = fileName;

        // Remove platform specific parts
        final platformParts = [
          '-x86_64-apple-darwin',
          '-x86_64-linux',
          '-x86_64.exe',
          '-x86_64-unknown-linux-gnu',
          '-x86_64-pc-windows-gnu',
          'x86_64-unknown-linux-gnu',
          'x86_64-apple-darwin',
          'x86_64-pc-windows-gnu',
          '-latest',
        ];
        for (final part in platformParts) {
          targetName = targetName.replaceAll(part, '');
        }
        // Remove version numbers (matches patterns like -0.1.7- or -v1.2.3-)
        targetName = targetName.replaceAll(RegExp(r'-v?\d+\.\d+\.\d+-?'), '');

        if (fileName == targetName) {
          continue;
        }

        final newPath = path.join(path.dirname(entity.path), targetName);
        await safeMove(entity, newPath);
      }
    }
  }

  // Helper function to safely move files/directories
  Future<void> safeMove(FileSystemEntity entity, String newPath) async {
    log.d('Moving ${entity.path} to $newPath');

    int retries = 0;
    final maxRetries = Platform.isWindows ? 5 : 1;

    while (retries < maxRetries) {
      try {
        await entity.rename(newPath);
        return; // Success! Exit function
      } on FileSystemException catch (e) {
        if (e.message.contains('Directory not empty') || e.message.contains('Rename failed')) {
          if (entity is File) {
            await File(newPath).delete();
            await entity.rename(newPath);
            return; // Success! Exit function
          } else {
            await Directory(newPath).delete(recursive: true);
            await entity.rename(newPath);
            return; // Success! Exit function
          }
        } else {
          retries++;
          if (retries < maxRetries) {
            log.i('Rename failed, retry $retries/$maxRetries after delay...');
            await Future.delayed(Duration(milliseconds: 500 * retries));
          } else {
            log.e('Failed to move: ${e.message}');
            rethrow;
          }
        }
      }
    }
  }
}
