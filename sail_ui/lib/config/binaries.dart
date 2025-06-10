import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/style/color_scheme.dart';
import 'package:sail_ui/utils/file_utils.dart';

abstract class Binary {
  Logger get log => GetIt.I.get<Logger>();

  final String name;
  final String version;
  final String description;
  final String repoUrl;
  final DirectoryConfig directories;
  MetadataConfig metadata;
  final String binary;
  final int port;
  final int chainLayer;
  List<String> extraBootArgs;
  final DownloadInfo downloadInfo;

  Binary({
    required this.name,
    required this.version,
    required this.description,
    required this.repoUrl,
    required this.directories,
    required this.metadata,
    required this.binary,
    required this.port,
    required this.chainLayer,
    this.extraBootArgs = const [],
    this.downloadInfo = const DownloadInfo(),
  });

  // Runtime properties
  Color get color;
  String get ticker => '';
  String get binaryName => binary;
  bool get isDownloaded => metadata.binaryPath != null;

  bool get updateAvailable =>
      isDownloaded && metadata.remoteTimestamp != null && metadata.remoteTimestamp != metadata.downloadedTimestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Binary && name == other.name && version == other.version;

  @override
  int get hashCode => Object.hash(name, version);

  static Binary? fromBinaryName(String binary) {
    final name = binary.toLowerCase();

    if (ParentChain().name.toLowerCase() == name) {
      return ParentChain();
    }

    if (Enforcer().name.toLowerCase() == name) {
      return Enforcer();
    }

    if (BitWindow().name.toLowerCase() == name) {
      return BitWindow();
    }

    if (Thunder().name.toLowerCase() == name) {
      return Thunder();
    }

    if (Bitnames().name.toLowerCase() == name) {
      return Bitnames();
    }

    if (BitAssets().name.toLowerCase() == name) {
      return BitAssets();
    }

    if (TestSidechain().name.toLowerCase() == name) {
      return TestSidechain();
    }

    if (ZCash().name.toLowerCase() == name) {
      return ZCash();
    }

    return null;
  }

  Binary copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
  });

  Future<void> wipeAppDir() async {
    _log('Starting data wipe for $name');

    final dir = datadir();

    switch (this) {
      case ParentChain():
        final signetDir = path.join(dir, 'signet');
        await _deleteFilesInDir(signetDir, [
          'anchors.dat',
          'banlist.json',
          'bitcoind.pid',
          'blocks',
          'chainstate',
          'fee_estimates.dat',
          'indexes',
          'mempool.dat',
          'peers.dat',
          'settings.json',
        ]);

      case Enforcer():
        await _deleteFilesInDir(dir, ['validator']);

      case BitWindow():
        await _deleteFilesInDir(dir, ['bitwindow.db', 'bitdrive']);

      case Bitnames():
        await _deleteFilesInDir(dir, [
          'data.mdb',
          'logs',
        ]);

      case BitAssets():
        await _deleteFilesInDir(dir, [
          'data.mdb',
          'logs',
        ]);

      case Thunder():
        await _deleteFilesInDir(dir, [
          'data.mdb',
          'logs',
          'start.sh',
          'thunder.conf',
          'thunder.zip',
          'thunder_app',
        ]);
    }
  }

  Future<void> wipeAssets(Directory assetsDir) async {
    _log('Starting asset wipe for $name in ${assetsDir.path}');

    final dir = assetsDir.path;

    // delete raw binary assets
    await _deleteFilesInDir(dir, [
      binary,
      binary.replaceAll('.exe', ''),
      '$binary.exe',
      '$binary.app',
      '$binary.meta',
    ]);

    // then any extra files for that specific chain
    switch (this) {
      case ParentChain():
        await _deleteFilesInDir(dir, [
          'bitcoin-cli',
          'bitcoin-util',
          'bitcoin-cli.exe',
          'bitcoin-util.exe',
          'qt', // a directory!
        ]);

      case Enforcer():
      // nothing extra

      case BitWindow():
        await _deleteFilesInDir(dir, [
          'data',
          'lib',
          'bitwindow.msix',
          'flutter_platform_alert_plugin.dll',
          'flutter_windows.dll',
          'screen_retriever_windows_plugin.dll',
          'url_launcher_windows_plugin.dll',
          'window_manager_plugin.dll',
        ]);

      case Bitnames():
        await _deleteFilesInDir(dir, [
          'bitnames-cli',
          'logs',
        ]);

      case BitAssets():
        await _deleteFilesInDir(dir, [
          'bitassets-cli',
          'logs',
        ]);

      case Thunder():
        await _deleteFilesInDir(dir, [
          'thunder-cli',
        ]);
    }
  }

  Future<void> _deleteFilesInDir(String dir, List<String> filesToWipe) async {
    for (final file in filesToWipe) {
      final filePath = path.join(dir, file);

      if (await FileSystemEntity.isDirectory(filePath)) {
        await Directory(filePath).delete(recursive: true);
      } else {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  Future<File> resolveBinaryPath(Directory? appDir) async {
    // First find all possible paths the binary might be in,
    // such as .exe, .app, /assets/bin, $datadir/assets etc.
    final possiblePaths = _getPossibleBinaryPaths(binary, appDir);

    // Check if binary exists in any of the possible paths
    for (final binaryPath in possiblePaths) {
      try {
        if (Directory(binaryPath).existsSync() || File(binaryPath).existsSync()) {
          var resolvedPath = binaryPath;
          // Handle .app bundles on macOS
          if (Platform.isMacOS && (binary.endsWith('.app'))) {
            resolvedPath = path.join(
              binaryPath,
              'Contents',
              'MacOS',
              path.basenameWithoutExtension(binaryPath),
            );
          }
          return File(resolvedPath);
        }
      } catch (e) {
        // Parent directory doesn't exist, continue to next path
        continue;
      }
    }

    final file = await writeBinaryFromAssetsBundle(appDir);
    log.i('Found binary in assets bundle: ${file.path}');

    return file;
  }

  Future<File> writeBinaryFromAssetsBundle(Directory? appDir) async {
    log.d('loading binary from assets bundle: $binary');
    ByteData? binResource;

    final binaryName = binary + (Platform.isWindows && !binary.endsWith('.exe') ? '.exe' : '');

    try {
      // add .exe if on windows and the binary doesn't already end with .exe
      final assetPath = 'bin/$binaryName';
      log.d('Attempting to load binary from asset path: $assetPath');

      binResource = await rootBundle.load(assetPath);
    } catch (e) {
      log.e('Failed to load binary $binaryName from assets bundle');
      throw Exception('Process: could not find binary $binaryName in any location. Error: $e');
    }
    log.d('successfully loaded binary from assets: $assetPath');

    File file;
    if (appDir != null) {
      final fileDir = binDir(appDir.path);
      await Directory(fileDir.path).create(recursive: true);
      file = File(filePath([fileDir.path, binaryName]));
      log.d('Writing binary to bin: ${file.path}');
    } else {
      // Create temp file
      final temp = await getTemporaryDirectory();
      final ts = DateTime.now();
      final randDir = Directory(
        filePath([temp.path, ts.millisecondsSinceEpoch.toString()]),
      );
      log.d('Creating temporary directory at: ${randDir.path}');
      await randDir.create();

      file = File(filePath([randDir.path, binaryName]));
      log.d('Writing binary to temporary file: ${file.path}');
    }

    log.d('Process: writing binary to ${file.path}');

    final buffer = binResource.buffer;
    await file.writeAsBytes(
      buffer.asUint8List(binResource.offsetInBytes, binResource.lengthInBytes),
    );
    log.d('Process: successfully wrote binary to assets');

    return file;
  }

  List<String> _getPossibleBinaryPaths(String baseBinary, Directory? appDir) {
    final paths = <String>[];
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

    if (kDebugMode) {
      // In debug mode, check pwd/bin first
      paths.addAll([
        path.join(Directory.current.path, 'bin', baseBinary),
      ]);
    }

    // Add launcher download paths based on binary type and platform
    if (home != null) {
      if (ParentChain().name == name) {
        switch (Platform.operatingSystem) {
          case 'linux':
            paths.add(
              path.join(
                home,
                '.drivechain-launcher',
                'binaries',
                'bitcoin',
                'L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu',
                'bitcoind',
              ),
            );
          case 'macos':
            paths.add(
              path.join(
                home,
                'Application Support',
                'binaries',
                'bitcoin',
                'L1-bitcoin-patched-latest-x86_64-apple-darwin',
                'bitcoind',
              ),
            );
          case 'windows':
            paths.add(
              path.join(
                home,
                'AppData',
                'Roaming',
                'binaries',
                'bitcoin',
                'L1-bitcoin-patched-latest-x86_64-w64-msvc',
                'bitcoind.exe',
              ),
            );
        }
      } else if (Enforcer().name == name) {
        switch (Platform.operatingSystem) {
          case 'linux':
            final binaryName = 'bip300301-enforcer-latest-x86_64-unknown-linux-gnu';
            paths.add(
              path.join(
                home,
                'Downloads',
                'Drivechain-Launcher-Downloads',
                'enforcer',
                binaryName,
                binaryName,
              ),
            );
          case 'macos':
            final binaryName = 'bip300301-enforcer-latest-x86_64-apple-darwin';
            paths.add(
              path.join(
                home,
                'Downloads',
                'Drivechain-Launcher-Downloads',
                'enforcer',
                binaryName,
                binaryName,
              ),
            );
          case 'windows':
            final binaryName = 'bip300301-enforcer-latest-x86_64-pc-windows-gnu';
            paths.add(
              path.join(
                home,
                'Downloads',
                'Drivechain-Launcher-Downloads',
                'enforcer',
                binaryName,
                '$binaryName.exe',
              ),
            );
        }
      }
    }

    if (appDir != null) {
      // In release mode, check the folder where binaries are downloaded to
      paths.addAll([
        path.join(appDir.path, 'bin', baseBinary),
      ]);
    }

    log.i('found possible paths $paths');

    return paths;
  }

  void _log(String message) {
    log.i('Binary: $message');
  }

  String get connectionString => '$name :$port';

  void addBootArg(String arg) {
    extraBootArgs = List<String>.from(extraBootArgs)..add(arg);
  }
}

class ParentChain extends Binary {
  ParentChain({
    super.name = 'Bitcoin Core (Patched)',
    super.version = 'latest',
    super.description = 'Modified Bitcoin implementation for drivechain support',
    super.repoUrl = 'https://github.com/drivechain-project/drivechain',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bitcoind',
    int? port,
    super.chainLayer = 1,
    super.downloadInfo = const DownloadInfo(),
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: '.drivechain',
                  OS.macos: 'Drivechain',
                  OS.windows: 'Drivechain',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'L1-bitcoin-patched-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'L1-bitcoin-patched-latest-x86_64-w64-msvc.zip',
                },
              ),
          port: port ?? 38332,
        );

  @override
  Color get color => SailColorScheme.green;

  @override
  ParentChain copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
  }) {
    return ParentChain(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
    );
  }
}

class BitWindow extends Binary {
  BitWindow({
    super.name = 'BitWindow',
    super.version = 'latest',
    super.description = 'GUI for managing drivechain operations',
    super.repoUrl = 'https://github.com/drivechain-project/bitwindow',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bitwindowd',
    int? port,
    super.chainLayer = 1,
    super.downloadInfo = const DownloadInfo(),
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: 'bitwindow',
                  OS.macos: 'bitwindow',
                  OS.windows: 'bitwindow',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'BitWindow-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'BitWindow-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'BitWindow-latest-x86_64-pc-windows-msvc.zip',
                },
              ),
          port: port ?? 8080,
        );

  @override
  Color get color => SailColorScheme.green;

  @override
  BitWindow copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
  }) {
    return BitWindow(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
    );
  }
}

class Enforcer extends Binary {
  Enforcer({
    super.name = 'BIP300301 Enforcer',
    super.version = '0.1.0',
    super.description = 'Manages drivechain validation rules',
    super.repoUrl = 'https://github.com/drivechain-project/enforcer',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bip300301-enforcer',
    int? port,
    super.chainLayer = 1,
    super.downloadInfo = const DownloadInfo(),
  }) : super(
          directories: directories ??
              DirectoryConfig(
                base: {
                  OS.linux: 'bip300301_enforcer',
                  OS.macos: 'bip300301_enforcer',
                  OS.windows: 'bip300301_enforcer',
                },
              ),
          metadata: metadata ??
              MetadataConfig(
                baseUrl: 'https://releases.drivechain.info/',
                files: {
                  OS.linux: 'bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip',
                  OS.macos: 'bip300301-enforcer-latest-x86_64-apple-darwin.zip',
                  OS.windows: 'bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip',
                },
              ),
          port: port ?? 50051,
        );

  @override
  Color get color => SailColorScheme.green;

  @override
  Enforcer copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
  }) {
    return Enforcer(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
    );
  }
}

extension BinaryPaths on Binary {
  String confFile() {
    return switch (this) {
      var b when b is TestSidechain => 'testchain.conf',
      var b when b is ZCash => 'zcash.conf',
      var b when b is ParentChain => 'bitcoin.conf',
      _ => throw 'unsupported binary type: $runtimeType',
    };
  }

  String logPath() {
    return switch (this) {
      var b when b is TestSidechain => filePath([datadir(), 'debug.log']),
      var b when b is ZCash => filePath([datadir(), 'regtest', 'debug.log']),
      var b when b is Thunder || b is Bitnames || b is BitAssets => _findLatestVersionedLog(),
      var b when b is ParentChain => filePath([datadir(), 'debug.log']),
      var b when b is BitWindow => filePath([datadir(), 'server.log']),
      var b when b is Enforcer => filePath([datadir(), 'bip300301_enforcer.log']),
      _ => throw 'unsupported binary type: $runtimeType',
    };
  }

  String _findLatestVersionedLog() {
    final logsDir = Directory(filePath([datadir(), 'logs']));
    if (!logsDir.existsSync()) {
      return filePath([datadir(), 'logs', 'unknown.log']);
    }

    // Get all version directories
    final versionDirs = logsDir
        .listSync()
        .whereType<Directory>()
        .where((dir) => dir.path.split(Platform.pathSeparator).last.startsWith('v'))
        .toList();

    if (versionDirs.isEmpty) {
      return filePath([datadir(), 'logs', 'unknown.log']); // Fallback if no version directories found
    }

    // Sort version directories by version number
    versionDirs.sort((a, b) {
      final aVersion = a.path.split(Platform.pathSeparator).last.substring(1); // Remove 'v' prefix
      final bVersion = b.path.split(Platform.pathSeparator).last.substring(1);

      // Split version numbers into components and compare each
      final aParts = aVersion.split('.').map(int.parse).toList();
      final bParts = bVersion.split('.').map(int.parse).toList();

      // Compare each part of the version number
      for (var i = 0; i < aParts.length && i < bParts.length; i++) {
        if (aParts[i] != bParts[i]) {
          return bParts[i].compareTo(aParts[i]); // Descending order
        }
      }

      // If all parts match up to the shorter length, longer version is newer
      return bParts.length.compareTo(aParts.length);
    });

    final latestVersionDir = versionDirs.first;

    // Get all log files in the latest version directory
    final logFiles = latestVersionDir.listSync().whereType<File>().where((file) => file.path.endsWith('.log')).toList();

    if (logFiles.isEmpty) {
      return filePath([datadir(), 'logs', 'unknown.log']); // Fallback if no log files found
    }

    // Sort log files by date in filename (YYYY-MM-DD.log format)
    logFiles.sort((a, b) {
      final aDate = a.path.split(Platform.pathSeparator).last.split('.')[0];
      final bDate = b.path.split(Platform.pathSeparator).last.split('.')[0];
      return bDate.compareTo(aDate); // Descending order
    });

    return logFiles.first.path;
  }

  String datadir() {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw 'unable to determine HOME location';
    }

    final subdir = directories.base[OS.current];
    if (subdir == null || subdir.isEmpty) {
      throw 'unsupported operating system, subdir is empty: ${Platform.operatingSystem}';
    }

    switch (OS.current) {
      case OS.linux:
        if (name == ParentChain().name) {
          // in good style, this is different than all the others
          return filePath([home, subdir]);
        }

        return filePath([home, '.local', 'share', subdir]);

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

extension BinaryDownload on Binary {
  /// Check if the binary exists in the assets directory
  Future<bool> exists(Directory datadir) async {
    // For macOS .app bundles, check for the .app directory
    if (Platform.isMacOS && binary.endsWith('.app')) {
      final appPath = assetPath(datadir);
      return Directory(appPath).existsSync();
    }

    if (Platform.isWindows && binary.endsWith('.msix')) {
      final appPath = assetPath(datadir);
      return Directory(appPath).existsSync();
    }

    // For regular binaries, check both with and without extension
    final baseNameToFind = path.basenameWithoutExtension(binary).toLowerCase();

    final assetsDir = binDir(datadir.path);
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
    return path.join(binDir(datadir.path).path, binary);
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

  /// Load when the file was last modified
  Future<(DateTime?, File?)> getCreationDate(Directory appDir) async {
    try {
      final binaryFile = await resolveBinaryPath(appDir);
      final stat = await binaryFile.stat();
      final lastModified = stat.modified;

      return (lastModified, binaryFile);
    } catch (e) {
      log.e('Binary does not exist anywhere $binary', error: e);
      return (null, null);
    }
  }
}

/// Configuration for component directories
class DirectoryConfig {
  final Map<OS, String> base;

  const DirectoryConfig({
    required this.base,
  });
}

/// Configuration for binary downloads
class MetadataConfig {
  final String baseUrl;
  final Map<OS, String> files;
  DateTime? remoteTimestamp; // Last-Modified from server
  DateTime? downloadedTimestamp; // Local file timestamp
  File? binaryPath; // Path to the binary on disk (if exists)

  MetadataConfig({
    required this.baseUrl,
    required this.files,
    this.remoteTimestamp,
    this.downloadedTimestamp,
    this.binaryPath,
  });

  MetadataConfig copyWith({
    String? baseUrl,
    Map<OS, String>? files,
    required DateTime? remoteTimestamp,
    required DateTime? downloadedTimestamp,
    required File? binaryPath,
  }) {
    return MetadataConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      files: files ?? this.files,
      remoteTimestamp: remoteTimestamp,
      downloadedTimestamp: downloadedTimestamp,
      binaryPath: binaryPath,
    );
  }
}

/// Represents the download status and information for a binary
class DownloadInfo {
  final double progress;
  final String? message;
  final String? error;
  final String? hash; // SHA256 of the binary
  final DateTime? downloadedAt;

  const DownloadInfo({
    this.progress = 0.0,
    this.message,
    this.error,
    this.hash,
    this.downloadedAt,
  });

  /// Create a copy with updated fields
  DownloadInfo copyWith({
    double? progress,
    String? message,
    String? error,
    String? hash,
    DateTime? downloadedAt,
  }) {
    return DownloadInfo(
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
      hash: hash ?? this.hash,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }
}
