import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

enum BinaryType {
  bitcoinCore,
  bitWindow,
  enforcer,
  testSidechain,
  zSide,
  thunder,
  bitnames,
  bitassets,
  grpcurl,
}

extension BinaryTypeExtension on BinaryType {
  Binary get binary => switch (this) {
    BinaryType.bitcoinCore => BitcoinCore(),
    BinaryType.bitWindow => BitWindow(),
    BinaryType.enforcer => Enforcer(),
    BinaryType.testSidechain => TestSidechain(),
    BinaryType.zSide => ZSide(),
    BinaryType.thunder => Thunder(),
    BinaryType.bitnames => BitNames(),
    BinaryType.bitassets => BitAssets(),
    BinaryType.grpcurl => GRPCurl(),
  };
}

abstract class Binary {
  Logger get log => GetIt.I.get<Logger>();

  final String name;
  final String version;
  final String description;
  final String repoUrl;
  final DirectoryConfig directories;
  MetadataConfig metadata;
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
    required this.port,
    required this.chainLayer,
    this.extraBootArgs = const [],
    this.downloadInfo = const DownloadInfo(),
  });

  // Runtime properties
  BinaryType get type;
  Color get color;
  String get ticker => '';
  String get binary => metadata.downloadConfig.binary;
  String get binaryName => binary;
  bool get isDownloaded => metadata.binaryPath != null;

  bool get updateAvailable =>
      isDownloaded &&
      metadata.remoteTimestamp != null &&
      metadata.remoteTimestamp!.isAfter(metadata.downloadedTimestamp!);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Binary &&
          name == other.name &&
          version == other.version &&
          description == other.description &&
          repoUrl == other.repoUrl &&
          binary == other.binary &&
          port == other.port &&
          chainLayer == other.chainLayer &&
          directories == other.directories &&
          metadata == other.metadata &&
          _listEquals(extraBootArgs, other.extraBootArgs) &&
          downloadInfo == other.downloadInfo;

  @override
  int get hashCode => Object.hash(
    name,
    version,
    description,
    repoUrl,
    binary,
    port,
    chainLayer,
    directories,
    metadata,
    extraBootArgs,
    downloadInfo,
  );

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Binary copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
  });

  Future<void> wipeAppDir() async {
    _log('Starting data wipe for $name');

    final dir = datadir();

    switch (type) {
      case BinaryType.bitcoinCore:
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

      case BinaryType.enforcer:
        await _deleteFilesInDir(dir, ['validator']);

      case BinaryType.bitWindow:
        await _deleteFilesInDir(dir, ['bitwindow.db', 'bitdrive']);

      case BinaryType.bitnames:
        await _deleteFilesInDir(dir, ['data.mdb', 'logs']);

      case BinaryType.bitassets:
        await _deleteFilesInDir(dir, ['data.mdb', 'logs']);

      case BinaryType.thunder:
        await _deleteFilesInDir(dir, ['data.mdb', 'logs', 'start.sh', 'thunder.conf', 'thunder.zip', 'thunder_app']);

      case BinaryType.testSidechain:
      case BinaryType.zSide:
      case BinaryType.grpcurl:
        // No specific cleanup for these types yet
        break;
    }
  }

  Future<void> deleteWallet() async {
    _log('Starting wallet backup for $name');

    final dir = datadir();

    switch (type) {
      case BinaryType.enforcer:
        await _renameWalletDir(dir, 'wallet');

      case BinaryType.bitnames:
        await _renameWalletDir(dir, 'wallet.mdb');

      case BinaryType.bitassets:
        await _renameWalletDir(dir, 'wallet.mdb');

      case BinaryType.thunder:
        await _renameWalletDir(dir, 'wallet.mdb');

      case BinaryType.zSide:
        await _renameWalletDir(dir, 'wallet.mdb');

      case BinaryType.bitcoinCore:
      case BinaryType.bitWindow:
      case BinaryType.testSidechain:
      case BinaryType.grpcurl:
        // No wallet for these types
        break;
    }
  }

  Future<void> _renameWalletDir(String dir, String walletName) async {
    final walletPath = path.join(dir, walletName);
    final walletFile = File(walletPath);
    final walletDir = Directory(walletPath);

    if (await walletFile.exists()) {
      // Handle wallet file
      final newName = await _findAvailableName(dir, walletName);
      final newPath = path.join(dir, newName);
      await walletFile.rename(newPath);
      _log('Renamed wallet file $walletName to $newName');
    } else if (await walletDir.exists()) {
      // Handle wallet directory
      final newName = await _findAvailableName(dir, walletName);
      final newPath = path.join(dir, newName);
      await walletDir.rename(newPath);
      _log('Renamed wallet directory $walletName to $newName');
    } else {
      _log('No wallet found at $walletPath');
    }
  }

  Future<String> _findAvailableName(String dir, String originalName) async {
    final baseName = path.basenameWithoutExtension(originalName);
    final extension = path.extension(originalName);

    // Try the original name first
    String candidateName = originalName;
    int counter = 2;

    while (await File(path.join(dir, candidateName)).exists() ||
        await Directory(path.join(dir, candidateName)).exists()) {
      candidateName = '$baseName-$counter$extension';
      counter++;
    }

    return candidateName;
  }

  Future<void> wipeAsset(Directory assetsDir) async {
    _log('Starting asset wipe for $name in ${assetsDir.path}');

    final dir = assetsDir.path;

    // delete raw binary assets
    await _deleteFilesInDir(dir, [binary, binary.replaceAll('.exe', ''), '$binary.exe', '$binary.app', '$binary.meta']);

    // then any extra files for that specific chain
    switch (type) {
      case BinaryType.bitcoinCore:
        await _deleteFilesInDir(dir, [
          'bitcoin-cli',
          'bitcoin-util',
          'bitcoin-cli.exe',
          'bitcoin-util.exe',
          'qt', // a directory!
        ]);

      case BinaryType.enforcer:
        // nothing extra
        break;

      case BinaryType.bitWindow:
        await _deleteFilesInDir(dir, [
          'data',
          'lib',
          'bitwindow.exe',
          'flutter_platform_alert_plugin.dll',
          'flutter_windows.dll',
          'screen_retriever_windows_plugin.dll',
          'url_launcher_windows_plugin.dll',
          'window_manager_plugin.dll',
        ]);

      case BinaryType.bitnames:
        await _deleteFilesInDir(dir, ['bitnames-cli']);

      case BinaryType.bitassets:
        await _deleteFilesInDir(dir, ['bitassets-cli']);

      case BinaryType.thunder:
        await _deleteFilesInDir(dir, ['thunder-cli']);

      case BinaryType.zSide:
        await _deleteFilesInDir(dir, ['thunder-orchard']);

      case BinaryType.testSidechain:
      case BinaryType.grpcurl:
        // No extra files for these types
        break;
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

  Future<File> resolveBinaryPath(Directory appDir) async {
    // First find all possible paths the binary might be in,
    // such as .exe, .app, /assets/bin, $datadir/assets etc.
    final possiblePaths = _getPossibleBinaryPaths(binary, appDir);

    // Check if binary exists in any of the possible paths
    for (final binaryPath in possiblePaths) {
      try {
        if (Directory(binaryPath).existsSync() || File(binaryPath).existsSync()) {
          var resolvedPath = binaryPath;
          // Handle .app bundles on macOS
          if (Platform.isMacOS && (resolvedPath.endsWith('.app'))) {
            resolvedPath = path.join(binaryPath, 'Contents', 'MacOS', path.basenameWithoutExtension(binaryPath));
          }
          return File(resolvedPath);
        }
      } catch (e) {
        // Parent directory doesn't exist, continue to next path
        continue;
      }
    }

    throw Exception('Binary not found');
  }

  List<String> _getPossibleBinaryPaths(String baseBinary, Directory appDir) {
    final paths = <String>[];

    if (kDebugMode) {
      // In debug mode, check pwd/bin first
      paths.addAll([path.join(binDir(Directory.current.path).path, baseBinary)]);
    }

    // Check the folder where binaries are downloaded to first
    paths.addAll([path.join(binDir(appDir.path).path, baseBinary)]);

    // finally check .app bundle on macos
    if (Platform.isMacOS) {
      if (!baseBinary.endsWith('.app')) {
        paths.addAll([path.join(binDir(appDir.path).path, '$baseBinary.app')]);
      }
    }
    // or .exe on windows
    if (Platform.isWindows) {
      if (!baseBinary.endsWith('.exe')) {
        paths.addAll([path.join(binDir(appDir.path).path, '$baseBinary.exe')]);
      }
    }

    return paths;
  }

  /// Check the Last-Modified header for a binary without downloading
  Future<DateTime?> _checkReleaseDate() async {
    try {
      // Handle GitHub API URLs differently
      if (metadata.downloadConfig.baseUrl.contains('github.com')) {
        return await _checkGithubReleaseDate();
      } else {
        return await _checkDirectReleaseDate();
      }
    } catch (e) {
      log.w('Warning: Failed to check release date for $name: $e');
      return null;
    }
  }

  Future<DateTime?> _checkGithubReleaseDate() async {
    try {
      // For GitHub-based releases, download binary directly from releases
      final response = await http.get(Uri.parse(metadata.downloadConfig.baseUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch GitHub release: ${response.statusCode}');
      }

      final publishedAt = json.decode(response.body)['published_at'] as String?;

      if (publishedAt == null) {
        log.w('Warning: No published_at field in GitHub release for $name');
        return null;
      }

      // Parse ISO 8601 timestamp from GitHub
      return DateTime.parse(publishedAt);
    } catch (e) {
      log.w('Warning: Failed to check GitHub release date for $name: $e');
      return null;
    }
  }

  Future<DateTime?> _checkDirectReleaseDate() async {
    try {
      final os = getOS();
      final fileName = metadata.downloadConfig.files[os];
      if (fileName == null || fileName.isEmpty || metadata.downloadConfig.baseUrl.isEmpty) {
        return null;
      }

      final downloadUrl = Uri.parse(metadata.downloadConfig.baseUrl).resolve(fileName).toString();

      final client = HttpClient();

      final request = await client.headUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        log.w('Warning: Could not check release date for $name: HTTP ${response.statusCode}');
        return null;
      }

      final lastModified = response.headers.value('last-modified');
      if (lastModified == null) {
        log.w('Warning: No Last-Modified header for $name');
        return null;
      }

      final releaseDate = HttpDate.parse(lastModified);
      return releaseDate;
    } catch (e) {
      log.w('Warning: Failed to check direct release date for $name: $e');
      return null;
    }
  }

  void _log(String message) {
    log.i('Binary: $message');
  }

  String get connectionString {
    // For BitcoinCore, get the actual port from BitcoinConfProvider which handles
    // both network defaults and user's custom rpcport setting
    if (type == BinaryType.bitcoinCore && port == 0) {
      try {
        final confProvider = GetIt.I.get<BitcoinConfProvider>();
        // The provider should expose the actual port being used
        final actualPort = confProvider.rpcPort;
        return '$name :$actualPort';
      } catch (e) {
        // Fallback if BitcoinConfProvider is not available
        return '$name :$port';
      }
    }
    return '$name :$port';
  }

  void addBootArg(String arg) {
    if (extraBootArgs.contains(arg)) {
      return;
    }

    extraBootArgs = List<String>.from(extraBootArgs)..add(arg);
  }
}

class BitcoinCore extends Binary {
  BitcoinCore({
    super.name = 'Bitcoin Core (Patched)',
    super.version = 'latest',
    super.description = 'Modified Bitcoin implementation for drivechain support',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/bitcoin-patched',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    int? port,
    super.chainLayer = 1,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs,
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {
                 OS.linux: '.drivechain',
                 OS.macos: 'Drivechain',
                 OS.windows: 'Drivechain',
               },
               flutterFrontend: {
                 OS.linux: '', // N/A
                 OS.macos: '', // N/A
                 OS.windows: '', // N/A
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'bitcoind',
                 files: {
                   OS.linux: 'L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'L1-bitcoin-patched-latest-x86_64-apple-darwin.zip',
                   OS.windows: 'L1-bitcoin-patched-latest-x86_64-w64-msvc.zip',
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         // Port is determined by network
         // mainnet: 8332, testnet: 18332, signet: 38332, regtest: 18443
         port: port ?? 0, // 0 means use network default
       );

  @override
  BinaryType get type => BinaryType.bitcoinCore;

  @override
  Color get color => SailColorScheme.green;

  @override
  BitcoinCore copyWith({
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
    return BitcoinCore(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
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
    super.repoUrl = 'https://github.com/LayerTwo-Labs/drivechain-frontends/bitwindow',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    int? port,
    super.chainLayer = 1,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs,
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {
                 OS.linux: 'bitwindow',
                 OS.macos: 'bitwindow',
                 OS.windows: 'bitwindow',
               },
               flutterFrontend: {
                 OS.linux: 'bitwindow',
                 OS.macos: 'bitwindow',
                 OS.windows: 'bitwindow',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 binary: 'bitwindowd',
                 baseUrl: '',
                 files: {
                   // should not be downloaded from any platform
                   OS.linux: '',
                   OS.macos: '',
                   OS.windows: '',
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 2122,
       );

  @override
  BinaryType get type => BinaryType.bitWindow;

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
    super.repoUrl = 'https://github.com/LayerTwo-Labs/bip300301-enforcer',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    int? port,
    super.chainLayer = 1,
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs,
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {
                 OS.linux: 'bip300301_enforcer',
                 OS.macos: 'bip300301_enforcer',
                 OS.windows: 'bip300301_enforcer',
               },
               flutterFrontend: {
                 OS.linux: '', // N/A
                 OS.macos: '', // N/A
                 OS.windows: '',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 baseUrl: 'https://releases.drivechain.info/',
                 binary: 'bip300301-enforcer',
                 files: {
                   OS.linux: 'bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'bip300301-enforcer-latest-x86_64-apple-darwin.zip',
                   OS.windows: 'bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip',
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 50051,
       );

  @override
  BinaryType get type => BinaryType.enforcer;

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
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
    );
  }
}

class GRPCurl extends Binary {
  GRPCurl({
    super.name = 'grpcurl',
    super.version = 'latest',
    super.description = 'Command-line tool for interacting with gRPC servers',
    super.repoUrl = 'https://github.com/fullstorydev/grpcurl',
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    int? port,
    super.chainLayer = 0, // Layer 0 = utility, not a blockchain
    super.downloadInfo = const DownloadInfo(),
    super.extraBootArgs,
  }) : super(
         directories:
             directories ??
             DirectoryConfig(
               binary: {
                 OS.linux: 'grpcurl',
                 OS.macos: 'grpcurl',
                 OS.windows: 'grpcurl',
               },
               flutterFrontend: {
                 OS.linux: 'grpcurl', // filled in so it just follows same code-path
                 OS.macos: 'grpcurl', // filled in so it just follows same code-path
                 OS.windows: 'grpcurl', // filled in so it just follows same code-path
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 baseUrl: 'https://api.github.com/repos/fullstorydev/grpcurl/releases/latest',
                 binary: 'grpcurl',
                 files: {
                   OS.linux: r'grpcurl_\d+\.\d+\.\d+_linux_x86_64\.tar\.gz',
                   OS.macos: r'grpcurl_\d+\.\d+\.\d+_osx_x86_64\.tar\.gz',
                   OS.windows: r'grpcurl_\d+\.\d+\.\d+_windows_x86_64\.zip',
                 },
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 0, // No port needed for utility binary
       );

  @override
  BinaryType get type => BinaryType.grpcurl;

  @override
  Color get color => SailColorScheme.green;

  @override
  GRPCurl copyWith({
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
    return GRPCurl(
      name: name,
      version: version ?? this.version,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      directories: directories ?? this.directories,
      metadata: metadata ?? this.metadata,
      port: port ?? this.port,
      chainLayer: chainLayer ?? this.chainLayer,
      downloadInfo: downloadInfo ?? this.downloadInfo,
    );
  }
}

extension BinaryPaths on Binary {
  String confFile() {
    return switch (type) {
      BinaryType.testSidechain => 'testchain.conf',
      BinaryType.zSide => 'zside.conf',
      BinaryType.bitcoinCore => _getBitcoinConfFile(),
      _ => throw 'unsupported binary type: $type',
    };
  }

  String _getBitcoinConfFile() {
    final datadir = BitcoinCore().datadir();

    // Always check for bitcoin.conf first - user config takes priority
    final bitcoinConfPath = File(path.join(datadir, 'bitcoin.conf'));
    if (bitcoinConfPath.existsSync()) {
      return 'bitcoin.conf';
    }

    // Fall back to our generated config
    return 'bitwindow-bitcoin.conf';
  }

  String logPath() {
    return switch (type) {
      BinaryType.testSidechain => filePath([datadir(), 'debug.log']),
      BinaryType.bitcoinCore => _getBitcoinLogPath(),
      BinaryType.bitWindow => filePath([datadir(), 'server.log']),
      BinaryType.thunder ||
      BinaryType.bitnames ||
      BinaryType.bitassets ||
      BinaryType.zSide => _findLatestDirVersionedLog(),
      BinaryType.enforcer => _findLatestEnforcerLog(),
      BinaryType.grpcurl => '', // No log file for grpcurl
    };
  }

  String _getBitcoinLogPath() {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();

    // Get network-specific subdirectory
    final networkDir = switch (confProvider.network) {
      Network.NETWORK_MAINNET => '', // mainnet uses root datadir
      Network.NETWORK_SIGNET => 'signet',
      Network.NETWORK_REGTEST => 'regtest',
      Network.NETWORK_TESTNET => 'testnet',
      _ => 'signet', // default to signet for unknown networks
    };

    return filePath([datadir(), networkDir, 'debug.log']);
  }

  String _findLatestEnforcerLog() {
    final logsDir = Directory(filePath([datadir(), 'logs']));

    if (!logsDir.existsSync()) {
      return filePath([datadir(), 'bip300301_enforcer.log']); // Fallback to original
    }

    // Find all enforcer log files matching the pattern: bip300301_enforcer.log.YYYY-MM-DD.N
    final logFiles = logsDir.listSync().whereType<File>().where((file) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      return fileName.startsWith('bip300301_enforcer.log.') &&
          RegExp(r'bip300301_enforcer\.log\.\d{4}-\d{2}-\d{2}\.\d+$').hasMatch(fileName);
    }).toList();

    if (logFiles.isEmpty) {
      return filePath([datadir(), 'bip300301_enforcer.log']); // Fallback to original
    }

    // Sort by date and sequence number (latest first)
    logFiles.sort((a, b) {
      final aFileName = a.path.split(Platform.pathSeparator).last;
      final bFileName = b.path.split(Platform.pathSeparator).last;

      // Extract date and sequence number from filename
      final aMatch = RegExp(r'bip300301_enforcer\.log\.(\d{4}-\d{2}-\d{2})\.(\d+)$').firstMatch(aFileName);
      final bMatch = RegExp(r'bip300301_enforcer\.log\.(\d{4}-\d{2}-\d{2})\.(\d+)$').firstMatch(bFileName);

      if (aMatch == null || bMatch == null) return 0;

      final aDate = aMatch.group(1)!;
      final bDate = bMatch.group(1)!;
      final aSeq = int.parse(aMatch.group(2)!);
      final bSeq = int.parse(bMatch.group(2)!);

      // First compare by date (descending)
      final dateComparison = bDate.compareTo(aDate);
      if (dateComparison != 0) return dateComparison;

      // If dates are equal, compare by sequence number (descending)
      return bSeq.compareTo(aSeq);
    });

    return logFiles.first.path;
  }

  String _findLatestDirVersionedLog() {
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

  String appdir() {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw 'unable to determine HOME location';
    }

    switch (OS.current) {
      case OS.linux:
        if (type == BinaryType.bitcoinCore) {
          // in good style, this is different than all the others
          return filePath([home]);
        }

        return filePath([home, '.local', 'share']);

      case OS.macos:
        return filePath([home, 'Library', 'Application Support']);
      case OS.windows:
        return filePath([home, 'AppData', 'Roaming']);
    }
  }

  String datadir() {
    final subdir = directories.binary[OS.current];
    if (subdir == null || subdir.isEmpty) {
      throw 'unsupported operating system, subdir is empty: ${Platform.operatingSystem}';
    }

    final appDir = appdir();
    return filePath([appDir, subdir]);
  }

  String frontendDir() {
    final subdir = directories.flutterFrontend[OS.current];
    if (subdir == null || subdir.isEmpty) {
      throw 'unsupported operating system, subdir is empty: ${Platform.operatingSystem}';
    }

    final appDir = appdir();
    return filePath([appDir, subdir]);
  }

  /// Fetch the binary's version by running it with --version flag
  Future<String> binaryVersion(Directory appDir) async {
    if (binary.endsWith('.app')) {
      return 'N/A';
    }

    try {
      final binaryFile = await resolveBinaryPath(appDir);

      final result =
          await Process.run(
            binaryFile.path,
            ['--version'],
            runInShell: true,
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Version check timed out'),
          );

      if (result.exitCode != 0) {
        return 'Version unavailable';
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) {
        return 'Unknown';
      }

      final lines = output.split('\n');
      if (lines.isEmpty) {
        return 'Unknown';
      }

      if (type == BinaryType.enforcer) {
        final versionLine = lines.firstWhere((line) => line.contains('bip300301_enforcer_lib'), orElse: () => '');
        final commitLine = lines.firstWhere((line) => line.trim().startsWith('commit:'), orElse: () => '');

        if (versionLine.isEmpty) {
          return lines.first;
        }

        final versionMatch = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(versionLine);
        final commitMatch = RegExp(r'commit:\s*([a-f0-9]+)').firstMatch(commitLine);

        if (versionMatch != null && commitMatch != null) {
          return '${versionMatch.group(1)!} (${commitMatch.group(1)!})';
        } else if (versionMatch != null) {
          return versionMatch.group(1)!;
        }

        return versionLine;
      }

      final versionMatch = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(output);
      if (versionMatch != null) {
        return versionMatch.group(1)!;
      }

      return lines.first;
    } catch (e) {
      log.w('Failed to get version for $name: $e');
      return 'Error: $e';
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

    if (Platform.isWindows && binary.endsWith('.exe')) {
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
  Future<(DateTime?, File?)> _getCreationDate(Directory appDir) async {
    try {
      final binaryFile = await resolveBinaryPath(appDir);
      final stat = await binaryFile.stat();
      final lastModified = stat.modified;

      return (lastModified, binaryFile);
    } catch (e) {
      return (null, null);
    }
  }

  /// Update metadata with current binary information
  Future<Binary> updateMetadata(Directory appDir) async {
    try {
      final updatedLocal = await updateLocalMetadata(appDir);
      final updatedReleaseDate = await updateReleaseDate(appDir);
      return copyWith(
        metadata: metadata.copyWith(
          remoteTimestamp: updatedReleaseDate.metadata.remoteTimestamp,
          downloadedTimestamp: updatedLocal.metadata.downloadedTimestamp,
          binaryPath: updatedLocal.metadata.binaryPath,
          updateable: updatedLocal.metadata.updateable,
        ),
      );
    } catch (e) {
      // Log error and return unchanged binary
      log.e('Error updating metadata for $name: $e');
      return this;
    }
  }

  /// Update metadata with current binary information
  Future<Binary> updateLocalMetadata(Directory appDir) async {
    try {
      // Load metadata from bin/ directory
      final (lastModified, binaryFile) = await _getCreationDate(appDir);
      final updateableBinary = binaryFile?.path.contains(appDir.path) ?? false;

      final updatedConfig = metadata.copyWith(
        remoteTimestamp: metadata.remoteTimestamp,
        downloadedTimestamp: lastModified,
        binaryPath: binaryFile,
        updateable: updateableBinary,
      );

      return copyWith(metadata: updatedConfig);
    } catch (e) {
      // Log error and return unchanged binary
      log.e('Error updating metadata for $name: $e');
      return this;
    }
  }

  /// Update metadata with current binary information
  Future<Binary> updateReleaseDate(Directory appDir) async {
    try {
      DateTime? serverReleaseDate;
      try {
        serverReleaseDate = await _checkReleaseDate();
      } catch (e) {
        log.e('could not check release date: $e');
      }

      final updatedConfig = metadata.copyWith(
        remoteTimestamp: serverReleaseDate,
        downloadedTimestamp: metadata.downloadedTimestamp,
        binaryPath: metadata.binaryPath,
        updateable: metadata.updateable,
      );

      return copyWith(metadata: updatedConfig);
    } catch (e) {
      // Log error and return unchanged binary
      log.e('Error updating release date for $name: $e');
      return this;
    }
  }
}

/// Configuration for component directories
class DirectoryConfig {
  final Map<OS, String> binary;
  final Map<OS, String> flutterFrontend;

  const DirectoryConfig({
    required this.binary,
    required this.flutterFrontend,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DirectoryConfig && _mapEquals(binary, other.binary);

  @override
  int get hashCode => binary.hashCode;

  bool _mapEquals(Map<OS, String> a, Map<OS, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class DownloadConfig {
  final String baseUrl;
  final String binary;
  final Map<OS, String> files;

  const DownloadConfig({
    required this.baseUrl,
    required this.binary,
    required this.files,
  });
}

/// Configuration for binary downloads
class MetadataConfig {
  // use settings provider to determine which download config to use
  final SettingsProvider _settingsProvider = GetIt.I.get<SettingsProvider>();
  final DownloadConfig _downloadConfig;
  final DownloadConfig? _alternativeDownloadConfig;

  // if test chains enabled, use those, but only if an alternative config exists
  DownloadConfig get downloadConfig =>
      _settingsProvider.useTestSidechains ? _alternativeDownloadConfig ?? _downloadConfig : _downloadConfig;

  DateTime? remoteTimestamp; // Last-Modified from server
  DateTime? downloadedTimestamp; // Local file timestamp
  File? binaryPath; // Path to the binary on disk (if exists)
  bool updateable; // Whether the binary can be updated

  MetadataConfig({
    required DownloadConfig downloadConfig,
    DownloadConfig? alternativeDownloadConfig,
    required this.updateable,
    required this.remoteTimestamp,
    required this.downloadedTimestamp,
    required this.binaryPath,
  }) : _alternativeDownloadConfig = alternativeDownloadConfig,
       _downloadConfig = downloadConfig;

  MetadataConfig copyWith({
    DownloadConfig? downloadConfig,
    DownloadConfig? alternativeDownloadConfig,
    required DateTime? remoteTimestamp,
    required DateTime? downloadedTimestamp,
    required File? binaryPath,
    required bool updateable,
  }) {
    return MetadataConfig(
      downloadConfig: downloadConfig ?? _downloadConfig,
      alternativeDownloadConfig: alternativeDownloadConfig ?? _alternativeDownloadConfig,
      remoteTimestamp: remoteTimestamp,
      downloadedTimestamp: downloadedTimestamp,
      binaryPath: binaryPath,
      updateable: updateable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MetadataConfig) return false;

    // Check alternative download config equality
    bool alternativeConfigsEqual;
    if (_alternativeDownloadConfig == null && other._alternativeDownloadConfig == null) {
      alternativeConfigsEqual = true;
    } else if (_alternativeDownloadConfig != null && other._alternativeDownloadConfig != null) {
      alternativeConfigsEqual = _mapEquals(_alternativeDownloadConfig.files, other._alternativeDownloadConfig.files);
    } else {
      // One is null, the other isn't
      alternativeConfigsEqual = false;
    }

    return _downloadConfig == other._downloadConfig &&
        updateable == other.updateable &&
        remoteTimestamp == other.remoteTimestamp &&
        downloadedTimestamp == other.downloadedTimestamp &&
        binaryPath?.path == other.binaryPath?.path &&
        _mapEquals(_downloadConfig.files, other._downloadConfig.files) &&
        alternativeConfigsEqual;
  }

  @override
  int get hashCode => Object.hash(
    _downloadConfig,
    _alternativeDownloadConfig,
    updateable,
    remoteTimestamp,
    downloadedTimestamp,
    binaryPath?.path,
  );

  bool _mapEquals(Map<OS, String> a, Map<OS, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Represents shutdown progress information
class ShutdownProgress {
  final int totalCount;
  final int completedCount;
  final String? currentBinary;
  final bool isForceKill;

  const ShutdownProgress({
    required this.totalCount,
    required this.completedCount,
    this.currentBinary,
    this.isForceKill = false,
  });
}

/// Represents the download status and information for a binary
class DownloadInfo {
  final double progress;
  final double total;
  final String? error;
  final String? message;
  final String? hash; // SHA256 of the binary
  final DateTime? downloadedAt;
  final bool isDownloading;

  double get progressPercent => progress / total;

  const DownloadInfo({
    this.progress = 0.0,
    this.total = 0.0,
    this.error,
    this.message,
    this.hash,
    this.downloadedAt,
    this.isDownloading = false,
  });

  /// Create a copy with updated fields
  DownloadInfo copyWith({
    double? progress,
    double? total,
    String? error,
    String? message,
    String? hash,
    DateTime? downloadedAt,
    bool? isDownloading,
  }) {
    return DownloadInfo(
      progress: progress ?? this.progress,
      total: total ?? this.total,
      error: error ?? this.error,
      message: message ?? this.message,
      hash: hash ?? this.hash,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadInfo &&
          progress == other.progress &&
          total == other.total &&
          error == other.error &&
          message == other.message &&
          hash == other.hash &&
          downloadedAt == other.downloadedAt &&
          isDownloading == other.isDownloading;

  @override
  int get hashCode => Object.hash(progress, total, error, hash, downloadedAt, isDownloading);
}
