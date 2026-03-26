import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

/// Manager responsible for downloading and extracting binaries to
/// the right place
class DownloadManager extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;
  late Map<BinaryType, Binary> _binariesMap;

  // Public getter returns a List for compatibility
  List<Binary> get binaries => List.unmodifiable(_binariesMap.values.toList());

  // Setter for compatibility - converts list back to map
  set binaries(List<Binary> newBinaries) {
    _binariesMap = {for (var b in newBinaries) b.type: b};
    notifyListeners();
  }

  // Private constructor
  DownloadManager._create({required this.appDir, required List<Binary> binaries}) {
    // Convert list to map keyed by BinaryType
    _binariesMap = {for (var b in binaries) b.type: b};
  }

  // Async factory
  static Future<DownloadManager> create({
    required Directory appDir,
    required List<Binary> initialBinaries,
  }) async {
    final binariesWithTimestamps = await loadBinaryCreationTimestamp(initialBinaries, appDir);

    // Fetch expected hashes for already-downloaded binaries
    Map<String, dynamic>? remoteHashes;
    try {
      final response = await http.get(Uri.parse('https://releases.drivechain.info/hashes.json'));
      if (response.statusCode == 200) {
        remoteHashes = json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // hashes.json not available yet, that's fine
    }

    final binariesWithHashes = <Binary>[];
    for (final binary in binariesWithTimestamps) {
      if (binary.isDownloaded && remoteHashes != null) {
        final fileName = binary.metadata.downloadConfig.files[GetIt.I.get<BitcoinConfProvider>().network]?[OS.current];
        String? expectedHash;
        if (fileName != null) {
          final entry = remoteHashes[fileName] as Map<String, dynamic>?;
          expectedHash = entry?['sha256'] as String?;
        }
        binariesWithHashes.add(
          binary.copyWith(
            downloadInfo: binary.downloadInfo.copyWith(expectedHash: expectedHash),
          ),
        );
      } else {
        binariesWithHashes.add(binary);
      }
    }

    return DownloadManager._create(appDir: appDir, binaries: binariesWithHashes);
  }

  // Test constructor (visible for mocking)
  @visibleForTesting
  DownloadManager.test({required this.appDir, required List<Binary> binaries}) {
    // Convert list to map keyed by BinaryType
    _binariesMap = {for (var b in binaries) b.type: b};
  }

  DownloadInfo getProgress(BinaryType type) {
    final binary = _binariesMap[type];
    if (binary == null) {
      return const DownloadInfo(progress: 0.0, isDownloading: false);
    }
    return binary.downloadInfo;
  }

  Future<void> downloadIfMissing(Binary binary, {bool shouldUpdate = false}) async {
    // Always use the current binary state from our internal map to avoid stale metadata
    var currentBinary = _binariesMap[binary.type] ?? binary;

    if (currentBinary.updateAvailable) {
      if (shouldUpdate) {
        // We have an available update, and the binary we use is in
        // appDir/assets/bin, so we go ahead and update it
        await _downloadBinary(currentBinary);
        return;
      } else {
        log.w('binary ${currentBinary.name} is not updateable');
      }
    }

    // refresh metadata just in case it is wiped about 1 millisecond ago..
    // and the directory watcher hasnt updated it yet
    currentBinary = await currentBinary.updateLocalMetadata(appDir);
    if (currentBinary.isDownloaded) {
      // We already have a binary, dont bother
      return;
    }

    await _downloadBinary(currentBinary);
  }

  /// Download and extract a binary
  Future<void> _downloadBinary(Binary binary) async {
    // Check if already downloading
    final currentlyDownloading = isDownloading(binary.type);
    if (currentlyDownloading) {
      log.i('Download already in progress for ${binary.name}, waiting for completion...');
      // Wait for the download to complete
      while (isDownloading(binary.type)) {
        await Future.delayed(const Duration(milliseconds: 100));
        log.i('download already in progress for ${binary.name}, waiting for it to finish...');
      }
      return;
    }

    log.i('Proceeding with download for ${binary.name}');

    try {
      await _downloadAndExtractBinary(binary);
    } catch (e) {
      updateBinary(
        binary.type,
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

  void updateBinary(BinaryType type, Binary Function(Binary) updater) {
    // Find by name to get the type (for backward compatibility)
    MapEntry<BinaryType, Binary>? entry;
    try {
      entry = _binariesMap.entries.firstWhere((e) => e.key == type);
    } catch (e) {
      log.w('Binary $type not found for update');
      return;
    }

    final oldBinary = entry.value;
    final newBinary = updater(oldBinary);

    // Only update and notify if there's an actual change
    if (oldBinary != newBinary) {
      _binariesMap[type] = newBinary;
      notifyListeners();
    }
  }

  bool isDownloading(BinaryType type) {
    final binary = _binariesMap[type];
    return binary != null && binary.downloadInfo.isDownloading;
  }

  /// Internal method to handle the actual download and extraction
  Future<void> _downloadAndExtractBinary(Binary binary) async {
    final network = GetIt.I.get<BitcoinConfProvider>().network;
    final baseUrl = binary.metadata.downloadConfig.baseUrl(network);
    if (baseUrl.isEmpty) {
      updateBinary(
        binary.type,
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

    updateBinary(
      binary.type,
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
    final subfolder = binary.metadata.downloadConfig.extractSubfolder?[network]?[OS.current] ?? '';
    final extractDir = Directory(path.join(binDir(appDir.path).path, subfolder));
    await downloadsDir.create(recursive: true);
    await extractDir.create(recursive: true);

    // Check if platform is supported
    final fileName = binary.metadata.downloadConfig.files[GetIt.I.get<BitcoinConfProvider>().network]![OS.current];
    if (fileName == null || fileName.isEmpty) {
      log.w('No download file found for ${binary.name} on ${OS.current}');
      return;
    }

    String filePath;
    String? localHash;
    int archiveSize = 0;
    String? expectedHash;
    try {
      if (baseUrl.contains('api.github.com')) {
        filePath = await _downloadGithubBinary(binary, downloadsDir, network);
      } else if (baseUrl.isNotEmpty) {
        filePath = await _downloadReleasesBinary(binary, downloadsDir, network);
      } else {
        updateBinary(
          binary.type,
          (b) => b.copyWith(
            downloadInfo: b.downloadInfo.copyWith(
              progress: 0.0,
              message: 'No download URL configured for ${binary.name}',
              isDownloading: false,
            ),
          ),
        );
        return;
      }

      // Verify hash before extraction
      updateBinary(
        binary.type,
        (b) => b.copyWith(
          downloadInfo: b.downloadInfo.copyWith(message: 'Verifying hash...'),
        ),
      );

      final archiveBytes = await File(filePath).readAsBytes();
      archiveSize = archiveBytes.length;
      localHash = sha256.convert(archiveBytes).toString();

      // Verify hash against release server
      log.i('Verifying hash for ${binary.name}: local=$localHash');

      expectedHash = await _fetchExpectedHash(binary);
      log.i('Release server hash for ${binary.name}: ${expectedHash ?? 'not available'}');

      if (expectedHash != null && expectedHash != localHash) {
        await File(filePath).delete();
        updateBinary(
          binary.type,
          (b) => b.copyWith(
            downloadInfo: DownloadInfo(
              error: 'Hash mismatch! Expected: $expectedHash, Got: $localHash',
              isDownloading: false,
              hash: localHash,
              expectedHash: expectedHash,
              hashMatch: false,
            ),
          ),
        );
        throw Exception('Binary hash verification failed for ${binary.name}');
      }

      // Extract the binary
      await _extractBinary(extractDir, filePath, downloadsDir, binary);

      // Update metadata immediately after extraction to set binaryPath
      final updatedBinary = await binary.updateMetadata(appDir);
      updateBinary(
        binary.type,
        (b) => b.copyWith(metadata: updatedBinary.metadata),
      );
    } catch (e) {
      // Update binary state to show error
      updateBinary(
        binary.type,
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
      await File(filePath).delete();
    } catch (e) {
      log.e('could not delete zip file: $e');
    }

    updateBinary(
      binary.type,
      (b) => b.copyWith(
        downloadInfo: DownloadInfo(
          message: 'Downloaded and extracted successfully',
          isDownloading: false,
          downloadedAt: DateTime.now(),
          progress: 1.0,
          total: 1.0,
          hash: localHash,
          expectedHash: expectedHash,
          hashMatch: expectedHash != null ? true : null,
        ),
      ),
    );

    // Write hash/size back to the chains config file
    if (GetIt.I.isRegistered<ChainsConfigProvider>()) {
      try {
        final configProvider = GetIt.I.get<ChainsConfigProvider>();
        final binaryKey = binaryTypeToJsonKey(binary.type);
        final osKey = switch (OS.current) {
          OS.linux => 'linux',
          OS.macos => 'macos',
          OS.windows => 'windows',
        };
        await configProvider.updateHashes(binaryKey, osKey, localHash, archiveSize);
      } catch (e) {
        log.w('Failed to write hash to chains config: $e');
      }
    }

    log.i('Successfully downloaded and extracted ${binary.name}');
  }

  Future<String> _downloadGithubBinary(Binary binary, Directory downloadsDir, BitcoinNetwork network) async {
    final baseUrl = binary.metadata.downloadConfig.baseUrl(network);
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'User-Agent': 'Drivechain-Frontends',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 403) {
      throw Exception(
        'GitHub API rate limit exceeded. Please wait a few minutes and try again, or download manually from $baseUrl',
      );
    }

    if (response.statusCode != 200) {
      throw Exception('GitHub API returned ${response.statusCode}. Please try again later.');
    }

    // Use the regex pattern from binary configuration
    final regexPattern = binary.metadata.downloadConfig.files[GetIt.I.get<BitcoinConfProvider>().network]![OS.current]!;
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
      await _downloadFile(downloadUrl, filePath, binary.type);
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

  Future<String> _downloadReleasesBinary(Binary binary, Directory downloadsDir, BitcoinNetwork network) async {
    // 2. Download the binary
    var zipName = binary.metadata.downloadConfig.files[network]![OS.current]!;
    final zipPath = path.join(downloadsDir.path, zipName);
    final baseUrl = binary.metadata.downloadConfig.baseUrl(network);
    final downloadUrl = Uri.parse(baseUrl).resolve(zipName).toString();
    await _downloadFile(downloadUrl, zipPath, binary.type);
    return zipPath;
  }

  /// Download a file
  Future<void> _downloadFile(String url, String savePath, BinaryType binaryType) async {
    log.i('_downloadFile started for $binaryType from $url');
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

      log.i('Download starting: totalBytes=$totalBytes, binaryName=$binaryType');

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
            downloadedMB = double.parse((receivedBytes / 1024 / 1024).toStringAsFixed(2));
            totalMB = double.parse((totalBytes / 1024 / 1024).toStringAsFixed(2));

            updateBinary(
              binaryType,
              (b) => b.copyWith(
                downloadInfo: DownloadInfo(
                  progress: downloadedMB, // i always want two decimals
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

      updateBinary(
        binaryType,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(
            progress: totalMB,
            total: totalMB,
            message: 'Downloaded complete',
            isDownloading: true, // still downloading, because we need to extract it as well
          ),
        ),
      );
      log.i('Download completed for $binaryType');
    } catch (e) {
      final error = 'Download failed from $url: $e\nSave path: $savePath';
      log.e('ERROR: $error');
      updateBinary(
        binaryType,
        (b) => b.copyWith(downloadInfo: DownloadInfo(progress: 0.0, message: error, isDownloading: false)),
      );
      rethrow;
    }
  }

  /// Fetch the expected SHA256 hash from releases.drivechain.info/hashes.json
  Future<String?> _fetchExpectedHash(Binary binary) async {
    final fileName = binary.metadata.downloadConfig.files[GetIt.I.get<BitcoinConfProvider>().network]?[OS.current];
    if (fileName == null) return null;

    try {
      final response = await http.get(Uri.parse('https://releases.drivechain.info/hashes.json'));
      if (response.statusCode != 200) return null;
      final hashes = json.decode(response.body) as Map<String, dynamic>;
      return (hashes[fileName] as Map<String, dynamic>?)?['sha256'] as String?;
    } catch (e) {
      log.w('Could not fetch hashes.json: $e');
      return null;
    }
  }

  /// Extract binary archive or process raw binary
  Future<void> _extractBinary(Directory extractDir, String filePath, Directory downloadsDir, Binary binary) async {
    final fileName = path.basename(filePath);

    if (fileName.endsWith('.zip')) {
      // extract the zip file
      await _extractZipFile(extractDir, filePath, downloadsDir, binary);
    } else if (fileName.endsWith('.tar.gz') || fileName.endsWith('.tgz')) {
      // extract the tar.gz file
      await _extractTarGzFile(extractDir, filePath, downloadsDir, binary);
    } else {
      // move the raw binary
      await _processRawBinary(extractDir, filePath, binary);
    }

    // Apply rename logic
    await _applyRenameLogic(extractDir);
  }

  /// Extract zip file (existing logic)
  Future<void> _extractZipFile(Directory extractDir, String zipPath, Directory downloadsDir, Binary binary) async {
    updateBinary(
      binary.type,
      (b) => b.copyWith(
        downloadInfo: DownloadInfo(progress: 0.9999, total: 1.0, isDownloading: true, message: 'Extracting archive...'),
      ),
    );

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

      updateBinary(
        binary.type,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(progress: 0.9999, total: 1.0, isDownloading: true, message: 'Moving files...'),
        ),
      );

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

      updateBinary(
        binary.type,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(progress: 0.9999, total: 1.0, isDownloading: true, message: 'Cleaning up...'),
        ),
      );

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

  /// Extract tar.gz file
  Future<void> _extractTarGzFile(Directory extractDir, String tarGzPath, Directory downloadsDir, Binary binary) async {
    updateBinary(
      binary.type,
      (b) => b.copyWith(
        downloadInfo: DownloadInfo(progress: 0.9999, total: 1.0, isDownloading: true, message: 'Extracting archive...'),
      ),
    );

    // Create a temporary directory for extraction
    final tempDir = Directory(path.join(extractDir.path, 'temp', path.basenameWithoutExtension(binary.binary)));
    try {
      await tempDir.delete(recursive: true);
    } catch (e) {
      // directory probably doesn't exist, swallow!
    }
    await tempDir.create(recursive: true);

    // Read the file bytes, decode gzip, then decode tar
    final bytes = await File(tarGzPath).readAsBytes();
    final gzipBytes = GZipDecoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(gzipBytes);

    try {
      await extractArchiveToDisk(archive, tempDir.path);

      updateBinary(
        binary.type,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(progress: 0.9999, total: 1.0, isDownloading: true, message: 'Moving files...'),
        ),
      );

      log.d('Moving files from temp directory to final location');
      await for (final entity in tempDir.list()) {
        final baseName = path.basename(entity.path);
        final targetPath = path.join(extractDir.path, baseName);

        if (entity is Directory) {
          // Flatten: move all files from nested dirs into extractDir
          await for (final innerEntity in entity.list(recursive: true)) {
            if (innerEntity is File) {
              final innerBaseName = path.basename(innerEntity.path);
              final targetFile = path.join(extractDir.path, innerBaseName);
              await safeMove(innerEntity, targetFile);
              if (!Platform.isWindows) {
                await Process.run('chmod', ['+x', targetFile]);
              }
            }
          }
          await entity.delete(recursive: true);
          continue;
        }

        await safeMove(entity, targetPath);
      }

      updateBinary(
        binary.type,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(
            progress: 0.9999,
            total: 1.0,
            isDownloading: true,
            message: 'Setting permissions...',
          ),
        ),
      );

      // Clean up temp directory
      await tempDir.delete(recursive: true);

      // Get the tar.gz name without extension
      final tarGzBaseName = path.basenameWithoutExtension(path.basenameWithoutExtension(tarGzPath));
      final expectedDirPath = path.join(extractDir.path, tarGzBaseName);

      if (await Directory(expectedDirPath).exists()) {
        final innerDir = Directory(expectedDirPath);

        for (final entity in innerDir.listSync()) {
          final entityBaseName = path.basename(entity.path);

          // Only extract the binary itself, skip LICENSE and other files
          if (entityBaseName == binary.binary ||
              entityBaseName == '${binary.binary}.exe' ||
              entityBaseName == path.basenameWithoutExtension(binary.binary)) {
            final newPath = path.join(extractDir.path, entityBaseName);
            await safeMove(entity, newPath);

            // Make binary executable on Unix-like systems
            if (!Platform.isWindows && entity is File) {
              await Process.run('chmod', ['+x', newPath]);
            }
          }
        }
        await innerDir.delete(recursive: true);
      }
    } catch (e) {
      log.e('Extraction error: $e\nStack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Process raw binary file
  Future<void> _processRawBinary(Directory extractDir, String binaryPath, Binary binary) async {
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
