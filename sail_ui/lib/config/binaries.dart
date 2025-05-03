import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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
  MetadataConfig metadata;
  final String binary;
  final NetworkConfig network;
  final int chainLayer;
  String? mnemonicSeedPhrasePath;

  Binary({
    required this.name,
    required this.version,
    required this.description,
    required this.repoUrl,
    required this.directories,
    required this.metadata,
    required this.binary,
    required this.network,
    required this.chainLayer,
    this.mnemonicSeedPhrasePath,
  });

  // Runtime properties
  Color get color;
  int get port => network.port;
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

    if (TestSidechain().name.toLowerCase() == name) {
      return TestSidechain();
    }

    if (ZCash().name.toLowerCase() == name) {
      return ZCash();
    }

    return null;
  }

  factory Binary.fromJson(Map<String, dynamic> json) {
    // First create the correct type based on name
    final name = json['name'] as String? ?? '';

    Binary base;
    if (name == ParentChain().name) {
      base = ParentChain();
    } else if (name == BitWindow().name) {
      base = BitWindow();
    } else if (name == Enforcer().name) {
      base = Enforcer();
    } else if (name == TestSidechain().name) {
      base = TestSidechain();
    } else if (name == ZCash().name) {
      base = ZCash();
    } else if (name == Thunder().name) {
      base = Thunder();
    } else if (name == Bitnames().name) {
      base = Bitnames();
    } else {
      base = _BinaryImpl(
        name: name,
        version: json['version'] as String? ?? '',
        description: json['description'] as String? ?? '',
        repoUrl: json['repo_url'] as String? ?? '',
        directories: DirectoryConfig.fromJson(json['directories'] as Map<String, dynamic>? ?? {}),
        metadata: MetadataConfig.fromJson(json['download'] as Map<String, dynamic>? ?? {}),
        binary: '',
        network: NetworkConfig.fromJson(json['network'] as Map<String, dynamic>? ?? {}),
        chainLayer: json['chain_layer'] as int? ?? 0,
      );
    }

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
      metadata: MetadataConfig.fromJson(json['download'] as Map<String, dynamic>? ?? {}),
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
    MetadataConfig? metadata,
    String? binary,
    NetworkConfig? network,
    int? chainLayer,
  });

  /// Check the Last-Modified header for a binary without downloading
  Future<DateTime?> checkReleaseDate() async {
    try {
      final os = getOS();
      final fileName = metadata.files[os]!;
      final downloadUrl = Uri.parse(metadata.baseUrl).resolve(fileName).toString();

      final client = HttpClient();

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
      return releaseDate;
    } catch (e) {
      _log('Warning: Failed to check release date for $name: $e');
      return null;
    }
  }

  /// Downloads and installs a binary
  Future<void> downloadAndExtract(
    Directory appDir,
    void Function({
      double progress,
      String? message,
      String? error,
    }) onStatusUpdate,
  ) async {
    try {
      onStatusUpdate(
        message: 'Starting download...',
      );

      // 1. Setup directories
      // 1. Setup paths - use the full datadir path
      final downloadsDir = Directory(path.join(appDir.path, 'assets', 'downloads'));
      final extractDir = Directory(path.join(appDir.path, 'assets'));
      final zipName = metadata.files[getOS()]!;
      final zipPath = path.join(downloadsDir.path, zipName);

      // Create downloads directory recursively, this will also
      // create the parent assets directory
      await downloadsDir.create(recursive: true);

      onStatusUpdate(
        message: 'Downloading...',
      );

      // 2. Download the binary
      final releaseDate = await checkReleaseDate();
      final downloadUrl = Uri.parse(metadata.baseUrl).resolve(zipName).toString();
      await _download(downloadUrl, zipPath, onStatusUpdate);

      // 3. Extract
      await _extract(extractDir, zipPath, downloadsDir);

      // 4. Get the newly downloaded binary path. Should and will exist because we just
      // downloaded and extracted correctly
      final binaryPath = await resolveBinaryPath(appDir);

      metadata = metadata.copyWith(
        remoteTimestamp: releaseDate,
        downloadedTimestamp: releaseDate,
        binaryPath: binaryPath,
      );

      // Update status to completed
      onStatusUpdate(
        message: 'Installed $name)',
      );
    } catch (e) {
      onStatusUpdate(
        error: e.toString(),
      );
      throw Exception(e);
    }
  }

  Future<void> _extract(Directory extractDir, String zipPath, Directory downloadsDir) async {
    // Create a temporary directory for extraction
    final tempDir = Directory(path.join(extractDir.path, 'temp', binary.split('.').first));
    try {
      await tempDir.delete(recursive: true);
    } catch (e) {
      // directory probably doesn't exist, swallow!
    }
    await tempDir.create(recursive: true);

    final inputStream = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeStream(inputStream);

    try {
      await extractArchiveToDisk(
        archive,
        tempDir.path,
      );

      // Helper function to safely move files/directories
      Future<void> safeMove(FileSystemEntity entity, String newPath) async {
        _log('Moving ${entity.path} to $newPath');
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
            _log('Failed to move: ${e.message}');
            rethrow;
          }
        }
      }

      _log('Moving files from temp directory to final location');
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

      // some binaries have additional naming conventions that convolutes things
      // such as versions, platform specific names, etc.
      // we must remove those extra bits, and rename the files that had their
      // names changed.
      await for (final entity in extractDir.list(recursive: false)) {
        if (entity is File) {
          final fileName = path.basename(entity.path);

          // Skip non-executable files
          if (fileName.endsWith('.zip') || fileName.endsWith('.meta') || fileName.endsWith('.md')) continue;

          // Clean up the filename:
          // 1. Remove version numbers (like -0.1.7-)
          // 2. Remove platform specifics (-x86_64-apple-darwin)
          // 3. Remove -latest if present
          String targetName = fileName;

          // First remove platform specific parts
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
      _log('Extraction error: $e\nStack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Downloads a file with progress tracking
  /// Returns the release date from the Last-Modified header
  Future<void> _download(
    String url,
    String savePath,
    void Function({
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
        message: 'Verifying download...',
      );
    } catch (e) {
      final error = 'Download failed from $url: $e\nSave path: $savePath';
      _log('ERROR: $error');
      throw Exception(error);
    }
  }

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
      final assetPath = 'assets/bin/$binaryName';
      log.d('Attempting to load binary from asset path: $assetPath');

      binResource = await rootBundle.load(assetPath);
    } catch (e) {
      log.e('Failed to load binary $binaryName from assets bundle');
      throw Exception('Process: could not find binary $binaryName in any location. Error: $e');
    }
    log.d('successfully loaded binary from assets: $assetPath');

    File file;
    if (appDir != null) {
      final fileDir = path.join(appDir.path, 'assets');
      await Directory(fileDir).create(recursive: true);
      file = File(filePath([fileDir, binaryName]));
      log.d('Writing binary to assets: ${file.path}');
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
      // In debug mode, check pwd/assets/bin first
      paths.addAll([
        path.join(Directory.current.path, 'assets', 'bin', baseBinary),
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
        path.join(appDir.path, 'assets', baseBinary),
      ]);
    }

    log.i('found possible paths $paths');

    return paths;
  }

  void _log(String message) {
    log.i('Binary: $message');
  }

  String get connectionString => '$name :${network.port}';
}

class ParentChain extends Binary {
  ParentChain({
    super.name = 'Bitcoin Core (Patched)',
    super.version = '0.1.0',
    super.description = 'Drivechain Parent Chain',
    super.repoUrl = 'https://github.com/drivechain-project/drivechain',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
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
          metadata: metadata ??
              MetadataConfig(
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
    MetadataConfig? metadata,
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
      metadata: metadata ?? this.metadata,
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
    MetadataConfig? metadata,
    super.binary = 'bitwindowd',
    NetworkConfig? network,
    super.chainLayer = 1,
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
    MetadataConfig? metadata,
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
      metadata: metadata ?? this.metadata,
      binary: binary ?? this.binary,
      network: network ?? this.network,
      chainLayer: chainLayer ?? this.chainLayer,
    );
  }
}

class Enforcer extends Binary {
  Enforcer({
    super.name = 'BIP300301 Enforcer',
    super.version = '0.1.0',
    super.description = 'BIP300/301 Enforcer',
    super.repoUrl = 'https://github.com/drivechain-project/enforcer',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    super.binary = 'bip300301-enforcer',
    NetworkConfig? network,
    super.chainLayer = 1,
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
    MetadataConfig? metadata,
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
      metadata: metadata ?? this.metadata,
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
      var b when b is ZCash => 'zcash.conf',
      var b when b is ParentChain => 'bitcoin.conf',
      _ => throw 'unsupported binary type: $runtimeType',
    };
  }

  String logPath() {
    return switch (this) {
      var b when b is TestSidechain => filePath([datadir(), 'debug.log']),
      var b when b is ZCash => filePath([datadir(), 'regtest', 'debug.log']),
      var b when b is Thunder => filePath([datadir(), 'logs', 'TODO.log']),
      var b when b is Bitnames => filePath([datadir(), 'logs', 'TODO.log']),
      var b when b is ParentChain => filePath([datadir(), 'debug.log']),
      var b when b is BitWindow => filePath([datadir(), 'server.log']),
      var b when b is Enforcer => filePath([datadir(), 'bip300301_enforcer.log']),
      _ => throw 'unsupported binary type: $runtimeType',
    };
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

class _BinaryImpl extends Binary {
  _BinaryImpl({
    required super.name,
    required super.version,
    required super.description,
    required super.repoUrl,
    required super.directories,
    required super.metadata,
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
    MetadataConfig? metadata,
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
      metadata: metadata ?? this.metadata,
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

    if (Platform.isWindows && binary.endsWith('.msix')) {
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

  /// Load when the file was last modified
  Future<(DateTime?, File?)> getCreationDate(Directory appDir) async {
    try {
      final binaryFile = await resolveBinaryPath(appDir);
      final stat = await binaryFile.stat();
      final lastModified = stat.modified;

      return (lastModified, binaryFile);
    } catch (e) {
      log.e('Failed to load metadata for $binary', error: e);
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

  factory DirectoryConfig.fromJson(Map<String, dynamic> json) {
    return DirectoryConfig(
      base: {
        OS.linux: json['linux'] as String? ?? 'Drivechain',
        OS.macos: json['darwin'] as String? ?? 'Drivechain',
        OS.windows: json['win32'] as String? ?? 'Drivechain',
      },
    );
  }
}

/// Configuration for binary downloads
class MetadataConfig {
  final String baseUrl;
  final Map<OS, String> files;
  DateTime? remoteTimestamp; // Last-Modified from server
  DateTime? downloadedTimestamp; // When we last downloaded it, what is saved to disk in .meta
  File? binaryPath; // Path to the binary on disk (if exists)

  MetadataConfig({
    required this.baseUrl,
    required this.files,
    this.remoteTimestamp,
    this.downloadedTimestamp,
    this.binaryPath,
  });

  factory MetadataConfig.fromJson(Map<String, dynamic> json) {
    final remoteStr = json['remote_timestamp'] as String?;
    final downloadedStr = json['downloaded_timestamp'] as String?;
    return MetadataConfig(
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

/// Information about a completed download
class DownloadMetadata {
  final DateTime? releaseDate; // Last-Modified date from server

  const DownloadMetadata({
    required this.releaseDate,
  });

  factory DownloadMetadata.fromJson(Map<String, dynamic> json) {
    return DownloadMetadata(
      releaseDate: json['releaseDate'] != null ? DateTime.parse(json['releaseDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'releaseDate': releaseDate?.toIso8601String(),
      };
}
