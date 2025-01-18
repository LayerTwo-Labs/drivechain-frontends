import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/style/color_scheme.dart';
import 'package:sail_ui/utils/file_utils.dart';

abstract class Binary {
  Logger get log => GetIt.I.get<Logger>();

  final String name;
  final String version;
  final String description;
  final String repoUrl;
  final DirectoryConfig directories;
  DownloadConfig download;
  final String binary;
  final NetworkConfig network;
  final int chainLayer;

  Binary({
    required this.name,
    required this.version,
    required this.description,
    required this.repoUrl,
    required this.directories,
    required this.download,
    required this.binary,
    required this.network,
    required this.chainLayer,
  });

  // Runtime properties
  Color get color;
  int get port => network.port;
  String get ticker => '';
  String get binaryName => binary;
  bool get updateAvailable =>
      download.remoteTimestamp != null &&
      (download.downloadedTimestamp == null || download.remoteTimestamp!.isAfter(download.downloadedTimestamp!));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Binary && name == other.name && version == other.version;

  @override
  int get hashCode => Object.hash(name, version);

  static Binary? fromBinary(String binary) {
    switch (binary.toLowerCase()) {
      case 'bitcoind':
        return ParentChain();
      case 'sidegeth':
        return EthereumSidechain();
      case 'testchaind':
        return TestSidechain();
      case 'zsided':
        return ZCashSidechain();
      case 'bitwindow':
        return BitWindow();
      case 'enforcer':
        return Enforcer();
      case 'thunder':
        return Thunder();
    }
    return null;
  }

  factory Binary.fromJson(Map<String, dynamic> json) {
    // First create the correct type based on name
    final name = json['name'] as String? ?? '';
    Binary base = switch (name) {
      'Bitcoin Core (Patched)' => ParentChain(),
      'BitWindow' => BitWindow(),
      'BIP300301 Enforcer' => Enforcer(),
      'Test Sidechain' => TestSidechain(),
      'zSide' => ZCashSidechain(),
      'EthSide' => EthereumSidechain(),
      'Thunder' => Thunder(),
      _ => _BinaryImpl(
          name: name,
          version: json['version'] as String? ?? '',
          description: json['description'] as String? ?? '',
          repoUrl: json['repo_url'] as String? ?? '',
          directories: DirectoryConfig.fromJson(json['directories'] as Map<String, dynamic>? ?? {}),
          download: DownloadConfig.fromJson(json['download'] as Map<String, dynamic>? ?? {}),
          binary: '', // Will be set by copyWith below
          network: NetworkConfig.fromJson(json['network'] as Map<String, dynamic>? ?? {}),
          chainLayer: json['chain_layer'] as int? ?? 0,
        ),
    };

    // Handle the binary field which is a map of platform-specific paths
    final binaryMap = json['binary'] as Map<String, dynamic>? ?? {};
    final binaryPath = switch (Platform.operatingSystem) {
          'linux' => binaryMap['linux'],
          'macos' => binaryMap['darwin'],
          'windows' => binaryMap['win32'],
          _ => throw Exception('unsupported platform')
        } as String? ??
        '';

    // Update fields from JSON, keeping the base type
    return base.copyWith(
      version: json['version'] as String? ?? '',
      description: json['description'] as String? ?? '',
      repoUrl: json['repo_url'] as String? ?? '',
      directories: DirectoryConfig.fromJson(json['directories'] as Map<String, dynamic>? ?? {}),
      download: DownloadConfig.fromJson(json['download'] as Map<String, dynamic>? ?? {}),
      binary: binaryPath,
      network: NetworkConfig.fromJson(json['network'] as Map<String, dynamic>? ?? {}),
      chainLayer: json['chain_layer'] as int? ?? 0,
    );
  }

  Binary copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  });

  /// Check the Last-Modified header for a binary without downloading
  Future<DateTime?> checkReleaseDate() async {
    try {
      final os = getOS();
      final fileName = download.files[os]!;
      final downloadUrl = Uri.parse(download.baseUrl).resolve(fileName).toString();

      final client = HttpClient();
      _log('Checking release date for $name at $downloadUrl');

      final request = await client.headUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        _log('Warning: Could not check release date for $name: HTTP ${response.statusCode}');
        return null;
      }

      final lastModified = response.headers.value('last-modified');
      if (lastModified == null) {
        _log('Warning: No Last-Modified header for $name');
        return null;
      }

      final releaseDate = HttpDate.parse(lastModified);
      _log('$name release date: $releaseDate');
      return releaseDate;
    } catch (e) {
      _log('Warning: Failed to check release date for $name: $e');
      return null;
    }
  }

  /// Downloads and installs a binary
  Future<DateTime> downloadAndExtract(
    Directory datadir,
    void Function(
      DownloadStatus status, {
      double progress,
      String? message,
      String? error,
    }) onStatusUpdate,
  ) async {
    try {
      onStatusUpdate(
        DownloadStatus.installing,
        message: 'Starting download...',
      );

      // 1. Setup directories
      final (fileName, downloadsDir, zipPath) = await _setupDirectories(datadir);
      onStatusUpdate(
        DownloadStatus.installing,
        message: 'Downloading...',
      );

      // 2. Download the binary
      final downloadUrl = Uri.parse(download.baseUrl).resolve(fileName).toString();
      final releaseDate = await _download(downloadUrl, zipPath, onStatusUpdate);

      // 3. Extract
      await _extract(datadir, zipPath, downloadsDir);

      // 4. Save metadata
      await saveMetadata(
        datadir,
        DownloadMetadata(
          releaseDate: releaseDate,
        ),
      );
      download = download.copyWith(
        remoteTimestamp: releaseDate,
        downloadedTimestamp: DateTime.now(),
      );

      // Update status to completed
      onStatusUpdate(
        DownloadStatus.installed,
        message: 'Installed $name)',
      );

      // 5. Finally, clean up downloads after everything else succeeded
      await _cleanup(downloadsDir.path);

      return releaseDate;
    } catch (e) {
      onStatusUpdate(
        DownloadStatus.failed,
        error: e.toString(),
      );
      throw Exception(e);
    }
  }

  Future<(String, Directory, String)> _setupDirectories(Directory datadir) async {
    final os = getOS();
    final fileName = download.files[os]!;

    // 1. Setup paths - use the full datadir path
    final downloadsDir = Directory(path.join(datadir.path, 'assets', 'downloads'));
    final zipPath = path.join(downloadsDir.path, fileName);

    _log('Downloads dir: ${downloadsDir.path}');
    _log('Zip path: $zipPath');

    // Create downloads directory recursively
    await downloadsDir.create(recursive: true);

    return (fileName, downloadsDir, zipPath);
  }

  Future<void> _extract(Directory datadir, String zipPath, Directory downloadsDir) async {
    final extension = path.extension(zipPath).toLowerCase();

    // Extract the archive
    if (extension == '.zip') {
      final inputStream = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      // If we're looking for a .app bundle
      if (Platform.isMacOS && binary.endsWith('.app')) {
        _log('Extracting .app bundle');

        // Extract everything - we need the full bundle structure
        await extractArchiveToDisk(archive, downloadsDir.path);

        // Find the .app directory in the extracted files
        await for (final entity in Directory(downloadsDir.path).list(recursive: false)) {
          if (entity is Directory && entity.path.endsWith('.app')) {
            _log('Found .app bundle: ${entity.path}');

            // Move the entire .app bundle to assets/
            final targetPath = path.join(datadir.path, 'assets', path.basename(entity.path));
            _log('Moving .app bundle to $targetPath');

            await Directory(path.dirname(targetPath)).create(recursive: true);
            await entity.rename(targetPath);
            return;
          }
        }
        throw Exception('Could not find .app bundle in extracted files');
      }

      // For non-.app binaries, continue with normal extraction...
      // Rest of the existing code for regular binaries
      await extractArchiveToDisk(archive, downloadsDir.path);
    } else if (extension == '.gz') {
      final bytes = await File(zipPath).readAsBytes();
      final gzBytes = GZipDecoder().decodeBytes(bytes);
      final tarArchive = TarDecoder().decodeBytes(gzBytes);
      await extractArchiveToDisk(tarArchive, downloadsDir.path);
    } else {
      throw Exception('could not extract archive: unsupported format $extension');
    }

    // Find and move binaries (only for files without extension)
    final binaryFiles = await _findBinaries(downloadsDir.path, datadir);
    if (binaryFiles.isEmpty) {
      throw Exception('No binary found in extracted files');
    }

    for (final binaryFile in binaryFiles) {
      final fileName = path.basename(binaryFile.path);
      final fileNameLower = fileName.toLowerCase();
      final extension = path.extension(fileName);

      // Determine target name based on whether it's a CLI binary, preserving extension
      final baseName = fileNameLower.contains('-cli') ? '$binary-cli' : binary;
      final targetName = extension.isEmpty ? baseName : '$baseName$extension';

      final finalBinaryPath = path.join(datadir.path, 'assets', targetName);
      _log('Moving binary from ${binaryFile.path} to $finalBinaryPath');

      // Create assets directory if it doesn't exist
      await Directory(path.dirname(finalBinaryPath)).create(recursive: true);

      // Copy the binary first
      await binaryFile.copy(finalBinaryPath);

      // Verify the copy was successful
      if (!await File(finalBinaryPath).exists()) {
        throw Exception('could not copy binary to final location');
      }
    }
  }

  /// Find all binary files recursively in a directory and move them to the assets directory
  Future<List<File>> _findBinaries(String sourceDirectory, Directory datadir) async {
    final dir = Directory(sourceDirectory);
    final foundBinaries = <File>[];
    final baseNameToFind = path.basenameWithoutExtension(binary).toLowerCase();
    _log('Looking for binary base name: $baseNameToFind');

    // First list all files and subdirectories
    final entries = await dir.list(recursive: false).toList();
    _log('Found ${entries.length} entries in directory');

    // Debug log all entries
    for (final entry in entries) {
      _log('Found in directory: ${entry.path} (${entry.runtimeType})');
    }

    // First check subdirectories for binaries
    for (final entry in entries) {
      if (entry is Directory) {
        // Look for binaries in first level subdirectories
        final subFiles = await entry.list(recursive: false).toList();
        for (final subFile in subFiles) {
          if (subFile is File) {
            final fileName = path.basename(subFile.path);
            final fileBaseName = path.basenameWithoutExtension(fileName).toLowerCase();
            _log('Examining file in subdirectory: $fileName (base: $fileBaseName)');

            if (fileBaseName.contains(baseNameToFind)) {
              final targetName = '$fileBaseName${path.extension(fileName)}';
              final finalBinaryPath = path.join(datadir.path, 'assets', targetName);

              _log('Moving binary from ${subFile.path} to $finalBinaryPath');
              await Directory(path.dirname(finalBinaryPath)).create(recursive: true);
              await subFile.copy(finalBinaryPath);

              final destFile = File(finalBinaryPath);
              if (!Platform.isWindows) {
                await Process.run('chmod', ['+x', destFile.path]);
              }

              foundBinaries.add(destFile);
            }
          }
        }
      }
    }

    // Then check root directory for binaries
    for (final entry in entries) {
      if (entry is File) {
        final fileName = path.basename(entry.path);
        final fileBaseName = path.basenameWithoutExtension(fileName).toLowerCase();
        _log('Examining file: $fileName (base: $fileBaseName)');

        if (fileBaseName.contains(baseNameToFind)) {
          final targetName = '$fileBaseName${path.extension(fileName)}';
          final finalBinaryPath = path.join(datadir.path, 'assets', targetName);

          _log('Moving binary from ${entry.path} to $finalBinaryPath');
          await Directory(path.dirname(finalBinaryPath)).create(recursive: true);
          await entry.copy(finalBinaryPath);

          final destFile = File(finalBinaryPath);
          if (!Platform.isWindows) {
            await Process.run('chmod', ['+x', destFile.path]);
          }

          foundBinaries.add(destFile);
        }
      }
    }

    if (foundBinaries.isEmpty) {
      _log('No matching binaries found. Directory contents:');
      for (final f in entries) {
        _log('  - ${f.path}');
      }
      throw Exception('could not find any matching binaries in extracted files');
    }

    return foundBinaries;
  }

  /// Downloads a file with progress tracking
  /// Returns the release date from the Last-Modified header
  Future<DateTime> _download(
    String url,
    String savePath,
    void Function(
      DownloadStatus status, {
      double progress,
      String? message,
      String? error,
    }) onStatusUpdate,
  ) async {
    try {
      final client = HttpClient();
      _log('Starting download for $name from $url to $savePath');

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
            _log('$name: Downloaded $downloadedMB MB / $totalMB MB (${(progress * 100).toStringAsFixed(1)}%)');
          }

          onStatusUpdate(
            DownloadStatus.installing,
            progress: progress,
            message: 'Downloading... $downloadedMB MB / $totalMB MB (${(progress * 100).toStringAsFixed(1)}%)',
          );
        }
      }

      await sink.close();
      client.close();

      _log('Download completed for $name');

      // Update status for next phase
      onStatusUpdate(
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

  void _log(String message) {
    log.i('Binary: $message');
  }
}

class ParentChain extends Binary {
  ParentChain({
    super.name = 'Bitcoin Core (Patched)',
    super.version = '0.1.0',
    super.description = 'Drivechain Parent Chain',
    super.repoUrl = 'https://github.com/drivechain-project/drivechain',
    DirectoryConfig? directories,
    DownloadConfig? download,
    super.binary = 'bitcoind',
    NetworkConfig? network,
    super.chainLayer = 1,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.drivechain',
                  OS.macos: 'Drivechain',
                  OS.windows: 'Drivechain',
                },
              ),
          download: download ??
              DownloadConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L1-bitcoin-patched-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L1-bitcoin-patched-latest-x86_64-w64-msvc.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 38332),
        );

  @override
  Color get color => SailColorScheme.green;

  @override
  ParentChain copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return ParentChain(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      download: download ?? this.download,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class BitWindow extends Binary {
  BitWindow({
    super.name = 'BitWindow',
    super.version = '0.1.0',
    super.description = 'BitWindow UI',
    super.repoUrl = 'https://github.com/drivechain-project/bitwindow',
    DirectoryConfig? directories,
    DownloadConfig? download,
    super.binary = 'bitwindowd',
    NetworkConfig? network,
    super.chainLayer = 1,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.bitwindow',
                  OS.macos: 'bitwindow',
                  OS.windows: 'bitwindow',
                },
              ),
          download: download ??
              DownloadConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'BitWindow-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'BitWindow-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'BitWindow-latest-x86_64-pc-windows-msvc.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 8080),
        );

  @override
  Color get color => SailColorScheme.green;

  @override
  BitWindow copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return BitWindow(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      download: download ?? this.download,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class Enforcer extends Binary {
  Enforcer({
    super.name = 'Enforcer',
    super.version = '0.1.0',
    super.description = 'BIP300/301 Enforcer',
    super.repoUrl = 'https://github.com/drivechain-project/enforcer',
    DirectoryConfig? directories,
    DownloadConfig? download,
    super.binary = 'bip300301_enforcer',
    NetworkConfig? network,
    super.chainLayer = 0,
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.enforcer',
                  OS.macos: 'bip300301_enforcer',
                  OS.windows: 'bip300301_enforcer',
                },
              ),
          download: download ??
              DownloadConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'bip300301-enforcer-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          network: network ?? NetworkConfig(port: 50051),
        );

  @override
  Color get color => SailColorScheme.green;

  @override
  Enforcer copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return Enforcer(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      download: download ?? this.download,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

extension BinaryPaths on Binary {
  String confFile() {
    return switch (this) {
      var b when b is TestSidechain => 'testchain.conf',
      var b when b is EthereumSidechain => 'config.toml',
      var b when b is ZCashSidechain => 'zcash.conf',
      var b when b is ParentChain => 'bitcoin.conf',
      _ => throw 'unsupported binary type: $runtimeType',
    };
  }

  String logDir() {
    return switch (this) {
      var b when b is TestSidechain => filePath([datadir(), 'debug.log']),
      var b when b is EthereumSidechain => filePath([datadir(), 'ethereum.log']),
      var b when b is ZCashSidechain => filePath([datadir(), 'regtest', 'debug.log']),
      var b when b is ParentChain => filePath([datadir(), 'debug.log']),
      _ => throw 'unsupported binary type: $runtimeType',
    };
  }

  String datadir() {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw 'unable to determine HOME location';
    }

    final subdir = directories.base[OS.current];
    if (subdir == null) {
      throw 'unsupported operating system: ${Platform.operatingSystem}';
    }

    switch (OS.current) {
      case OS.linux:
        return filePath([home, subdir]);
      case OS.macos:
        return filePath([home, 'Library', 'Application Support', subdir]);
      case OS.windows:
        return filePath([home, 'AppData', 'Roaming', subdir]);
    }
  }
}

/// Join a list of filepath segments based on the underlying platform
/// path separator
String filePath(List<String> segments) {
  return segments.where((element) => element.isNotEmpty).join(Platform.pathSeparator);
}

class _BinaryImpl extends Binary {
  _BinaryImpl({
    required super.name,
    required super.version,
    required super.description,
    required super.repoUrl,
    required super.directories,
    required super.download,
    required super.binary,
    required super.network,
    required super.chainLayer,
  });

  @override
  Color get color => SailColorScheme.green;

  @override
  Binary copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    DownloadConfig? download,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  }) {
    return _BinaryImpl(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      download: download ?? this.download,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

extension BinaryDownload on Binary {
  /// Check if the binary exists in the assets directory
  Future<bool> exists(Directory datadir) async {
    // For macOS .app bundles, check for the .app directory
    if (Platform.isMacOS && binary.endsWith('.app')) {
      final appPath = path.join(datadir.path, 'assets', binary);
      return Directory(appPath).existsSync();
    }

    // For regular binaries, check both with and without extension
    final baseNameToFind = path.basenameWithoutExtension(binary).toLowerCase();

    final assetsDir = Directory(path.join(datadir.path, 'assets'));
    if (!assetsDir.existsSync()) return false;

    try {
      final files = assetsDir.listSync();
      return files.any((entity) {
        if (entity is! File) return false;
        final fileName = path.basename(entity.path);
        final fileBaseName = path.basenameWithoutExtension(fileName).toLowerCase();
        return fileBaseName == baseNameToFind;
      });
    } catch (e) {
      _log('Error checking binary existence: $e');
      return false;
    }
  }

  /// Get the path to the binary in assets
  String assetPath(Directory datadir) {
    return path.join(datadir.path, 'assets', binary);
  }

  /// Calculate SHA256 hash of the binary
  Future<String?> calculateHash(Directory datadir) async {
    try {
      final file = File(assetPath(datadir));
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      return sha256.convert(bytes).toString();
    } catch (e) {
      return null;
    }
  }

  /// Load metadata about the downloaded binary
  Future<DownloadMetadata?> loadMetadata(Directory datadir) async {
    try {
      final metaFile = File(path.join(datadir.path, 'assets', '$binary.meta'));
      if (!await metaFile.exists()) return null;

      final json = jsonDecode(await metaFile.readAsString());
      return DownloadMetadata.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Save metadata about the downloaded binary
  Future<void> saveMetadata(Directory datadir, DownloadMetadata meta) async {
    final metaFile = File(path.join(datadir.path, 'assets', '$binary.meta'));
    await metaFile.writeAsString(jsonEncode(meta.toJson()));
  }
}

/// Configuration for component directories
class DirectoryConfig {
  final Map<OS, String> base;

  const DirectoryConfig({
    required this.base,
  });

  factory DirectoryConfig.fromJson(Map<String, dynamic> json) {
    return DirectoryConfig(
      base: {
        OS.linux: json['linux'] as String? ?? '',
        OS.macos: json['darwin'] as String? ?? '',
        OS.windows: json['win32'] as String? ?? '',
      },
    );
  }
}

/// Configuration for binary downloads
class DownloadConfig {
  final String baseUrl;
  final Map<OS, String> files;
  DateTime? remoteTimestamp; // Last-Modified from server
  DateTime? downloadedTimestamp; // When we last downloaded it, what is saved to disk in .meta

  DownloadConfig({
    required this.baseUrl,
    required this.files,
    this.remoteTimestamp,
    this.downloadedTimestamp,
  });

  factory DownloadConfig.fromJson(Map<String, dynamic> json) {
    final remoteStr = json['remote_timestamp'] as String?;
    final downloadedStr = json['downloaded_timestamp'] as String?;
    return DownloadConfig(
      baseUrl: json['base_url'] as String,
      files: {
        OS.linux: (json['files'] as Map<String, dynamic>)['linux'] as String? ?? '',
        OS.macos: (json['files'] as Map<String, dynamic>)['darwin'] as String? ?? '',
        OS.windows: (json['files'] as Map<String, dynamic>)['win32'] as String? ?? '',
      },
      remoteTimestamp: remoteStr != null ? DateTime.parse(remoteStr) : null,
      downloadedTimestamp: downloadedStr != null ? DateTime.parse(downloadedStr) : null,
    );
  }

  DownloadConfig copyWith({
    String? baseUrl,
    Map<OS, String>? files,
    DateTime? remoteTimestamp,
    DateTime? downloadedTimestamp,
  }) {
    return DownloadConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      files: files ?? this.files,
      remoteTimestamp: remoteTimestamp ?? this.remoteTimestamp,
      downloadedTimestamp: downloadedTimestamp ?? this.downloadedTimestamp,
    );
  }
}

/// Configuration for network settings
class NetworkConfig {
  final int port;

  const NetworkConfig({
    required this.port,
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) {
    return NetworkConfig(
      port: json['port'] as int? ?? 0,
    );
  }
}

/// Represents the download status and information for a binary
class DownloadInfo {
  final DownloadStatus status;
  final double progress;
  final String? message;
  final String? error;
  final String? hash; // SHA256 of the binary
  final DateTime? downloadedAt;

  const DownloadInfo({
    this.status = DownloadStatus.uninstalled,
    this.progress = 0.0,
    this.message,
    this.error,
    this.hash,
    this.downloadedAt,
  });

  /// Create a copy with updated fields
  DownloadInfo copyWith({
    DownloadStatus? status,
    double? progress,
    String? message,
    String? error,
    String? hash,
    DateTime? downloadedAt,
  }) {
    return DownloadInfo(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
      hash: hash ?? this.hash,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }
}

enum DownloadStatus {
  uninstalled, // Binary not present in assets/
  installing, // Currently downloading/extracting/moving
  installed, // Binary present in assets/ with metadata
  failed, // Installation failed with error
}

/// Information about a completed download
class DownloadMetadata {
  final DateTime releaseDate; // Last-Modified date from server

  const DownloadMetadata({
    required this.releaseDate,
  });

  factory DownloadMetadata.fromJson(Map<String, dynamic> json) {
    return DownloadMetadata(
      releaseDate: DateTime.parse(json['releaseDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'releaseDate': releaseDate.toIso8601String(),
      };
}
