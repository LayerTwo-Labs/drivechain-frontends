import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:sail_ui/utils/file_utils.dart';

/// Manager responsible for downloading and extracting binaries to
/// the right place
class DownloadManager extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;
  late List<Binary> binaries;
  void Function(String name, Binary Function(Binary) updater) updateBinary;

  DownloadManager({
    required this.appDir,
    required this.binaries,
    required this.updateBinary,
  });

  DownloadInfo getProgress(String binaryName) {
    final binary = binaries.firstWhere((b) => b.name == binaryName);
    return binary.downloadInfo;
  }

  Stream<Map<String, DownloadInfo>> get progressStream {
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      return Map.fromEntries(
        binaries.map((b) => MapEntry(b.name, b.downloadInfo)),
      );
    });
  }

  Future<void> downloadIfMissing(Binary binary) async {
    if (binary.updateAvailable) {
      if (binary.metadata.updateable) {
        // We have an available update, and the binary we use is in
        // appDir/assets/bin, so we go ahead and update it
        return await _downloadBinary(binary);
      } else {
        log.w('binary ${binary.name} is not updateable');
      }
    }

    if (binary.isDownloaded) {
      // We already have a binary, dont boether
      return;
    }

    await _downloadBinary(binary);
  }

  /// Download and extract a binary
  Future<void> _downloadBinary(Binary binary) async {
    // Check if already downloading
    if (isDownloading(binary)) {
      log.i('Download already in progress for ${binary.name}, waiting for completion...');
      // Wait for the download to complete
      while (isDownloading(binary)) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    try {
      await _downloadAndExtractBinary(binary);
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: const DownloadInfo(progress: 1.0, message: 'Download completed'),
        ),
      );
      log.i('Successfully downloaded and extracted ${binary.name}');
    } catch (e) {
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(progress: 0.0, error: 'Download failed: $e'),
        ),
      );
      log.e('Download failed for ${binary.name}: $e');
      rethrow;
    }
  }

  void _updateBinary(String name, Binary Function(Binary) updater) {
    updateBinary(name, updater);
    notifyListeners();
  }

  bool isDownloading(Binary binary) {
    return binary.downloadInfo.progress > 0.0 && binary.downloadInfo.progress < 1.0;
  }

  /// Internal method to handle the actual download and extraction
  Future<void> _downloadAndExtractBinary(Binary binary) async {
    // 1. Setup directories
    final downloadsDir = Directory(path.join(appDir.path, 'downloads'));
    final extractDir = binDir(appDir.path);
    await downloadsDir.create(recursive: true);
    await extractDir.create(recursive: true);

    // 2. Download the binary
    final zipName = binary.metadata.files[OS.current]!;
    final zipPath = path.join(downloadsDir.path, zipName);
    final downloadUrl = Uri.parse(binary.metadata.baseUrl).resolve(zipName).toString();
    await _downloadFile(downloadUrl, zipPath, binary.name);

    // 3. Extract
    await _extractBinary(extractDir, zipPath, downloadsDir, binary);

    final releaseDate = await binary.checkReleaseDate();
    // Update binary metadata
    final binaryPath = await binary.resolveBinaryPath(appDir);
    // only updateable if it is inside the appDir
    final updateableBinary = binaryPath.path.contains(appDir.path);
    _updateBinary(
      binary.name,
      (b) => b.copyWith(
        metadata: b.metadata.copyWith(
          remoteTimestamp: releaseDate,
          downloadedTimestamp: releaseDate,
          binaryPath: binaryPath,
          updateable: updateableBinary,
        ),
      ),
    );

    // Delete the zip file
    await File(zipPath).delete();
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

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes != -1) {
          final progress = receivedBytes / totalBytes;
          final currentPercentStr = (progress * 100).toStringAsFixed(1);

          // Only update if the percentage display would change
          if (currentPercentStr != lastPercentStr) {
            final downloadedMB = (receivedBytes / 1024 / 1024).toStringAsFixed(1);
            final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(1);

            _updateBinary(
              binaryName,
              (b) => b.copyWith(
                downloadInfo: DownloadInfo(
                  progress: progress,
                  message: 'Downloaded $downloadedMB MB / $totalMB MB ($currentPercentStr%)',
                ),
              ),
            );

            lastPercentStr = currentPercentStr;
          }
        }
      }

      await sink.close();
      client.close();

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
          ),
        ),
      );
      throw Exception(error);
    }
  }

  /// Extract binary archive
  Future<void> _extractBinary(
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

      // Helper function to safely move files/directories
      Future<void> safeMove(FileSystemEntity entity, String newPath) async {
        log.d('Moving ${entity.path} to $newPath');
        try {
          await entity.rename(newPath);
        } on FileSystemException catch (e) {
          if (e.message.contains('Directory not empty') || e.message.contains('Rename failed')) {
            if (entity is File) {
              await File(newPath).delete();
              await entity.rename(newPath);
            } else {
              await Directory(newPath).delete(recursive: true);
              await entity.rename(newPath);
            }
          } else {
            log.e('Failed to move: ${e.message}');
            rethrow;
          }
        }
      }

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
    } catch (e) {
      log.e('Extraction error: $e\nStack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
