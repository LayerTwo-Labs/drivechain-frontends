import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

// Re-export BinaryType so callers that only import this file (the historical
// home of the now-deleted Dart enum) keep working without an extra import.
export 'package:sail_ui/gen/orchestrator/v1/orchestrator.pbenum.dart' show BinaryType;

const kBitwindowBitcoinConfFilename = 'bitwindow-bitcoin.conf';

Never _unsupportedBinaryType(BinaryType t) => throw StateError('unsupported BinaryType: $t');

/// Default-constructed [Binary] for a proto [BinaryType]. Throws on
/// UNSPECIFIED — that value only ever surfaces from the wire and indicates
/// the orchestrator named a binary the frontend doesn't recognise.
Binary defaultBinaryFor(BinaryType type) => switch (type) {
  BinaryType.BINARY_TYPE_BITCOIND => BitcoinCore(),
  BinaryType.BINARY_TYPE_BITWINDOWD => BitWindow(),
  BinaryType.BINARY_TYPE_ENFORCER => Enforcer(),
  BinaryType.BINARY_TYPE_ZSIDE => ZSide(),
  BinaryType.BINARY_TYPE_THUNDER => Thunder(),
  BinaryType.BINARY_TYPE_BITNAMES => BitNames(),
  BinaryType.BINARY_TYPE_BITASSETS => BitAssets(),
  BinaryType.BINARY_TYPE_TRUTHCOIN => Truthcoin(),
  BinaryType.BINARY_TYPE_PHOTON => Photon(),
  BinaryType.BINARY_TYPE_COINSHIFT => CoinShift(),
  BinaryType.BINARY_TYPE_GRPCURL => GRPCurl(),
  BinaryType.BINARY_TYPE_ORCHESTRATORD => Orchestratord(),
  BinaryType.BINARY_TYPE_ZSIDED => ZSided(),
  BinaryType.BINARY_TYPE_LIQUID_SIGNET => LiquidSignet(),
  _ => _unsupportedBinaryType(type),
};

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

  // Whether Layer Two Labs develops and vets this binary. Override to false for
  // third-party binaries so the UI can warn before downloading them.
  bool get developedByLayerTwoLabs => true;

  bool get updateAvailable =>
      isDownloaded &&
      metadata.remoteTimestamp != null &&
      metadata.downloadedTimestamp != null &&
      metadata.remoteTimestamp!.isAfter(metadata.downloadedTimestamp!);

  // Process log storage (in-memory, session-based)
  List<ProcessLogEntry> startupLogs = [];

  void addStartupLog(DateTime timestamp, String message) {
    startupLogs.add(ProcessLogEntry(timestamp: timestamp, message: message));

    if (startupLogs.length > 1000) {
      startupLogs.removeAt(0);
    }
  }

  void clearProcessLogs() {
    startupLogs.clear();
  }

  // Check if process has recent log activity (within last 30 seconds)
  bool get hasRecentStartupLogActivity {
    if (startupLogs.isEmpty) return false;
    final lastLog = startupLogs.last;
    final now = DateTime.now();
    return now.difference(lastLog.timestamp).inSeconds < 30;
  }

  // Override in subclasses to define interesting log patterns
  List<RegExp> get startupLogPatterns => [];

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

    throw Exception('Binary not found');
  }

  List<String> _getPossibleBinaryPaths(String baseBinary, Directory appDir) {
    final paths = <String>[];
    final network = GetIt.I.get<BitcoinConfProvider>().network;
    final subfolder = metadata.downloadConfig.extractSubfolder?[network]?[OS.current] ?? '';

    // When the user has flipped test sidechains on for an L2, orchestratord
    // extracts the alt build to bin/test/<binary>/ — on macOS that's a
    // Thunder.app-style bundle (Contents/MacOS/<TitleCase>), elsewhere a
    // plain executable. Mirror sidechain-orchestrator/config.go
    // TestSidechainBinaryPath so chain-settings reads the right mtime
    // instead of the (likely missing) prod-path binary.
    if (chainLayer == 2 && GetIt.I.get<SettingsProvider>().useTestSidechains) {
      final testDir = Directory(path.join(binDir(appDir.path).path, 'test', baseBinary));
      if (testDir.existsSync()) {
        if (Platform.isMacOS) {
          for (final entry in testDir.listSync()) {
            if (entry is Directory && entry.path.endsWith('.app')) {
              final appName = path.basenameWithoutExtension(entry.path);
              paths.add(path.join(entry.path, 'Contents', 'MacOS', appName));
            }
          }
        } else if (Platform.isWindows) {
          paths.add(path.join(testDir.path, '$baseBinary.exe'));
        } else {
          paths.add(path.join(testDir.path, baseBinary));
        }
      }
    }

    if (kDebugMode) {
      paths.addAll([
        path.join(binDir(Directory.current.path).path, subfolder, baseBinary),
      ]);
    }

    paths.addAll([path.join(binDir(appDir.path).path, subfolder, baseBinary)]);

    // For L1 binaries, also check BitWindow's assets directory
    // This allows sidechains to reuse already-downloaded binaries
    final isCurrentlyBitwindow = appDir.path.toLowerCase().contains(
      'bitwindow',
    );
    if (chainLayer == 1 && !isCurrentlyBitwindow) {
      final bitwindowDir = path.join(appDir.parent.path, 'bitwindow');
      final binaryPath = path.join(
        binDir(bitwindowDir).path,
        subfolder,
        baseBinary,
      );
      paths.add(binaryPath);
      if (Platform.isWindows && !baseBinary.endsWith('.exe')) {
        paths.add('$binaryPath.exe');
      }
    }

    // finally check .app bundle on macos
    if (Platform.isMacOS) {
      if (!baseBinary.endsWith('.app')) {
        paths.addAll([
          path.join(binDir(appDir.path).path, subfolder, '$baseBinary.app'),
        ]);
      }
    }
    // or .exe on windows
    if (Platform.isWindows) {
      if (!baseBinary.endsWith('.exe')) {
        paths.addAll([
          path.join(binDir(appDir.path).path, subfolder, '$baseBinary.exe'),
        ]);
      }
    }

    return paths;
  }

  /// Check the Last-Modified header for a binary without downloading
  Future<DateTime?> _checkReleaseDate() async {
    try {
      // Handle GitHub API URLs differently
      final network = GetIt.I.get<BitcoinConfProvider>().network;
      if (metadata.downloadConfig.baseUrl(network).contains('github.com')) {
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
    final url = metadata.downloadConfig.baseUrl(
      GetIt.I.get<BitcoinConfProvider>().network,
    );

    // Check cache first
    final cached = _GitHubCache.get(url);
    if (cached != null) {
      return cached;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Drivechain-Frontends',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 403) {
        _GitHubCache.set(url, null); // Cache the failure too
        return null;
      }

      if (response.statusCode != 200) {
        _GitHubCache.set(url, null);
        return null;
      }

      final publishedAt = json.decode(response.body)['published_at'] as String?;

      if (publishedAt == null) {
        log.d('No published_at field in GitHub release for $name');
        _GitHubCache.set(url, null);
        return null;
      }

      final releaseDate = DateTime.parse(publishedAt);
      _GitHubCache.set(url, releaseDate); // Cache the result
      return releaseDate;
    } catch (e) {
      log.d(
        'Could not check GitHub release date for $name: ${e.toString().split('\n').first}',
      );
      _GitHubCache.set(url, null); // Cache the failure
      return null;
    }
  }

  Future<DateTime?> _checkDirectReleaseDate() async {
    try {
      final os = getOS();
      final fileName = metadata.downloadConfig.files[GetIt.I.get<BitcoinConfProvider>().network]?[os];
      final baseUrl = metadata.downloadConfig.baseUrl(
        GetIt.I.get<BitcoinConfProvider>().network,
      );
      if (fileName == null || fileName.isEmpty || baseUrl.isEmpty) {
        return null;
      }

      final downloadUrl = Uri.parse(baseUrl).resolve(fileName).toString();
      final useTest = GetIt.I.isRegistered<SettingsProvider>()
          ? GetIt.I.get<SettingsProvider>().useTestSidechains
          : false;
      final hasAlt = metadata.hasAlternativeDownloadConfig;
      log.w('_checkDirectReleaseDate $name: useTest=$useTest hasAlt=$hasAlt url=$downloadUrl');

      final client = HttpClient();

      final request = await client.headUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        log.w(
          'Warning: Could not check release date for $name: HTTP ${response.statusCode}',
        );
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
    if (type == BinaryType.BINARY_TYPE_BITCOIND && port == 0) {
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

  void addBootArg(String arg, {bool override = false}) {
    // If override is true, first remove any existing args with the same key
    if (override) {
      // Extract the key (everything before '=')
      final key = arg.split('=').first;
      // Remove any existing args with the same key
      extraBootArgs = List<String>.from(extraBootArgs)
        ..removeWhere((existingArg) => existingArg.split('=').first == key);
    }

    // Don't add if exact arg already exists
    if (extraBootArgs.contains(arg)) {
      return;
    }

    extraBootArgs = List<String>.from(extraBootArgs)..add(arg);
  }
}

// Global cache for GitHub API responses (1 minute TTL)
class _GitHubCache {
  static final Map<String, _CacheEntry> _cache = {};

  static DateTime? get(String url) {
    final entry = _cache[url];
    if (entry == null) return null;

    // Check if cache entry is still valid (1 minute TTL)
    if (DateTime.now().difference(entry.timestamp).inMinutes >= 1) {
      _cache.remove(url);
      return null;
    }

    return entry.releaseDate;
  }

  static void set(String url, DateTime? releaseDate) {
    _cache[url] = _CacheEntry(releaseDate, DateTime.now());
  }
}

class _CacheEntry {
  final DateTime? releaseDate;
  final DateTime timestamp;

  _CacheEntry(this.releaseDate, this.timestamp);
}

class BitcoinCore extends Binary {
  BitcoinCore({
    super.name = 'Bitcoin Core',
    super.version = '30.2',
    super.description = 'Bitcoin Core',
    super.repoUrl = 'https://github.com/bitcoin/bitcoin',
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
                 ...allNetworks({
                   OS.linux: '.drivechain',
                   OS.macos: 'Drivechain',
                   OS.windows: 'Drivechain',
                 }),
                 BitcoinNetwork.BITCOIN_NETWORK_MAINNET: {
                   OS.linux: '.bitcoin',
                   OS.macos: 'Bitcoin',
                   OS.windows: 'Bitcoin',
                 },
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
                 baseUrls: {
                   ...allNetworksUrl(
                     'https://bitcoincore.org/bin/bitcoin-core-30.2/',
                   ),
                   BitcoinNetwork.BITCOIN_NETWORK_FORKNET: 'https://releases.drivechain.info/',
                 },
                 binary: 'bitcoind',
                 files: {
                   ...allNetworks({
                     OS.linux: 'bitcoin-30.2-x86_64-linux-gnu.tar.gz',
                     OS.macos: 'bitcoin-30.2-x86_64-apple-darwin.tar.gz',
                     OS.windows: 'bitcoin-30.2-win64.zip',
                   }),
                   BitcoinNetwork.BITCOIN_NETWORK_FORKNET: {
                     OS.linux: 'L1-drivechain-forknet-x86_64-unknown-linux-gnu.zip',
                     OS.macos: 'L1-drivechain-forknet-x86_64-apple-darwin.zip',
                     OS.windows: 'L1-drivechain-forknet-x86_64-w64-msvc.zip',
                   },
                 },
                 extractSubfolder: {
                   BitcoinNetwork.BITCOIN_NETWORK_FORKNET: {
                     OS.linux: 'forknet',
                     OS.macos: 'forknet',
                     OS.windows: 'forknet',
                   },
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
  BinaryType get type => BinaryType.BINARY_TYPE_BITCOIND;

  @override
  Color get color => SailColorScheme.green;

  @override
  List<RegExp> get startupLogPatterns => [
    RegExp(r'init message:'),
    RegExp(r'Verifying last \d+ blocks'),
    RegExp(r'Verification progress: \d+%'),
    RegExp(r'Verification: No coin database inconsistencies'),
    RegExp(r'Loading block index'),
    RegExp(r'Done loading'),
    RegExp(r'Synchronizing blockheaders'),
    RegExp(r'Rescan completed in'),
    RegExp(r'Rescan started from block'),
  ];

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
               binary: allNetworks({
                 OS.linux: 'bitwindow',
                 OS.macos: 'bitwindow',
                 OS.windows: '10520LayertwoLabs/BitWindow',
               }),
               flutterFrontend: {
                 OS.linux: 'bitwindow',
                 OS.macos: 'bitwindow',
                 OS.windows: '10520LayertwoLabs/BitWindow',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 binary: 'bitwindowd',
                 baseUrls: allNetworksUrl(''),
                 // should not be downloaded from any platform
                 files: allNetworks({
                   OS.linux: '',
                   OS.macos: '',
                   OS.windows: '',
                 }),
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 30301,
       );

  @override
  BinaryType get type => BinaryType.BINARY_TYPE_BITWINDOWD;

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

class Orchestratord extends Binary {
  Orchestratord({
    super.name = 'Orchestratord',
    super.version = 'latest',
    super.description = 'Sidechain orchestrator daemon',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/drivechain-frontends/orchestrator',
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
               binary: allNetworks({
                 OS.linux: 'orchestratord',
                 OS.macos: 'orchestratord',
                 OS.windows: 'orchestratord',
               }),
               flutterFrontend: {
                 OS.linux: 'orchestratord',
                 OS.macos: 'orchestratord',
                 OS.windows: 'orchestratord',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 binary: 'orchestratord',
                 baseUrls: allNetworksUrl(''),
                 files: allNetworks({
                   OS.linux: '',
                   OS.macos: '',
                   OS.windows: '',
                 }),
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 30400,
       );

  @override
  BinaryType get type => BinaryType.BINARY_TYPE_ORCHESTRATORD;

  @override
  Color get color => SailColorScheme.orange;

  @override
  Orchestratord copyWith({
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
    return Orchestratord(
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

class ZSided extends Binary {
  ZSided({
    super.name = 'ZSided',
    super.version = 'latest',
    super.description = 'ZSide sidechain orchestrator daemon',
    super.repoUrl = 'https://github.com/LayerTwo-Labs/drivechain-frontends/zside/server',
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
               binary: allNetworks({
                 OS.linux: 'zside',
                 OS.macos: 'zside',
                 OS.windows: 'zside',
               }),
               flutterFrontend: {
                 OS.linux: 'zside',
                 OS.macos: 'zside',
                 OS.windows: 'zside',
               },
             ),
         metadata:
             metadata ??
             MetadataConfig(
               downloadConfig: DownloadConfig(
                 binary: 'zsided',
                 baseUrls: allNetworksUrl(''),
                 files: allNetworks({
                   OS.linux: '',
                   OS.macos: '',
                   OS.windows: '',
                 }),
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 30303,
       );

  @override
  BinaryType get type => BinaryType.BINARY_TYPE_ZSIDED;

  @override
  Color get color => SailColorScheme.blue;

  @override
  ZSided copyWith({
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
    return ZSided(
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
               binary: allNetworks({
                 OS.linux: 'bip300301_enforcer',
                 OS.macos: 'bip300301_enforcer',
                 OS.windows: 'bip300301_enforcer',
               }),
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
                 baseUrls: allNetworksUrl('https://releases.drivechain.info/'),
                 binary: 'bip300301-enforcer',
                 files: allNetworks({
                   OS.linux: 'bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip',
                   OS.macos: 'bip300301-enforcer-latest-x86_64-apple-darwin.zip',
                   OS.windows: 'bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip',
                 }),
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 50051,
       );

  @override
  BinaryType get type => BinaryType.BINARY_TYPE_ENFORCER;

  @override
  Color get color => SailColorScheme.green;

  @override
  List<RegExp> get startupLogPatterns => [
    RegExp(r'Starting up bip300301_enforcer'),
    RegExp(r'verified mainchain REST server is enabled'),
    RegExp(r'verified mainchain REST server at'),
    RegExp(r'created mainchain JSON-RPC client'),
    RegExp(r'Connected to mainchain client network=\w+ blocks=\d+'),
    RegExp(r'Created validator DBs in'),
    RegExp(r'Instantiating \w+ wallet'),
    RegExp(r'creating esplora client esplora_url='),
    RegExp(r'esplora client initialized height=\d+'),
    RegExp(r'Created database connection to'),
    RegExp(r'Loaded existing BDK wallet'),
    RegExp(r'wallet inner: wired together components'),
    RegExp(r'Listening for JSON-RPC on'),
    RegExp(r'Listening for gRPC on'),
    RegExp(r'Connected to ZMQ server'),
    RegExp(r'Reached main tip at height \d+!'),
    RegExp(r'Synced \d+ headers in'),
    RegExp(r'starting batched sync'),
    RegExp(r'Synced batch of \d+ blocks in'),
    RegExp(r'Synced \d+ blocks in'),
    RegExp(r'enforcer synced to tip!'),
    RegExp(r'Initial mempool sync complete'),
    RegExp(r'initial_mempool_sync:'),
  ];

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
               binary: allNetworks({
                 OS.linux: 'grpcurl',
                 OS.macos: 'grpcurl',
                 OS.windows: 'grpcurl',
               }),
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
                 baseUrls: allNetworksUrl(
                   'https://api.github.com/repos/fullstorydev/grpcurl/releases/latest',
                 ),
                 binary: 'grpcurl',
                 files: allNetworks({
                   OS.linux: r'grpcurl_\d+\.\d+\.\d+_linux_x86_64\.tar\.gz',
                   OS.macos: r'grpcurl_\d+\.\d+\.\d+_osx_x86_64\.tar\.gz',
                   OS.windows: r'grpcurl_\d+\.\d+\.\d+_windows_x86_64\.zip',
                 }),
               ),
               remoteTimestamp: null,
               downloadedTimestamp: null,
               binaryPath: null,
               updateable: false,
             ),
         port: port ?? 0, // No port needed for utility binary
       );

  @override
  BinaryType get type => BinaryType.BINARY_TYPE_GRPCURL;

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

/// Pure helper: returns the Flutter frontend's getApplicationSupportDirectory()
/// path for [type] given [os] and [home]. Tests pass synthetic values so the
/// path mapping can be exercised without touching dart:io.
String? flutterFrontendDirFor(BinaryType type, OS os, String home) {
  return switch (type) {
    BinaryType.BINARY_TYPE_BITWINDOWD => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'bitwindow'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'BitWindow'),
      OS.linux => path.join(home, '.local', 'share', 'bitwindow'),
    },
    BinaryType.BINARY_TYPE_THUNDER => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'com.layertwolabs.thunder'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'Thunder'),
      OS.linux => path.join(home, '.local', 'share', 'com.layertwolabs.thunder'),
    },
    BinaryType.BINARY_TYPE_ZSIDE => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'com.layertwolabs.zside'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'ZSide'),
      OS.linux => path.join(home, '.local', 'share', 'com.layertwolabs.zside'),
    },
    BinaryType.BINARY_TYPE_BITNAMES => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'com.layertwolabs.bitnames'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'BitNames'),
      OS.linux => path.join(home, '.local', 'share', 'com.layertwolabs.bitnames'),
    },
    BinaryType.BINARY_TYPE_BITASSETS => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'com.layertwolabs.bitassets'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'BitAssets'),
      OS.linux => path.join(home, '.local', 'share', 'com.layertwolabs.bitassets'),
    },
    BinaryType.BINARY_TYPE_TRUTHCOIN => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'com.layertwolabs.truthcoin'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'Truthcoin'),
      OS.linux => path.join(home, '.local', 'share', 'com.layertwolabs.truthcoin'),
    },
    BinaryType.BINARY_TYPE_PHOTON => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'com.layertwolabs.photon'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'Photon'),
      OS.linux => path.join(home, '.local', 'share', 'com.layertwolabs.photon'),
    },
    BinaryType.BINARY_TYPE_COINSHIFT => switch (os) {
      OS.macos => path.join(home, 'Library', 'Application Support', 'com.layertwolabs.coinshift'),
      OS.windows => path.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'Coinshift'),
      OS.linux => path.join(home, '.local', 'share', 'com.layertwolabs.coinshift'),
    },
    BinaryType.BINARY_TYPE_BITCOIND ||
    BinaryType.BINARY_TYPE_ENFORCER ||
    BinaryType.BINARY_TYPE_GRPCURL ||
    BinaryType.BINARY_TYPE_ORCHESTRATORD ||
    BinaryType.BINARY_TYPE_ZSIDED => null,
    BinaryType.BINARY_TYPE_UNSPECIFIED => _unsupportedBinaryType(type),
    _ => _unsupportedBinaryType(type),
  };
}

extension BinaryPaths on Binary {
  String confFile() {
    return switch (type) {
      BinaryType.BINARY_TYPE_BITCOIND => () {
        final network = GetIt.I.get<BitcoinConfProvider>().network;
        // For mainnet, use standard Bitcoin datadir; otherwise use Drivechain datadir (respects custom datadir)
        final confDir = network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET
            ? path.join(BitcoinCore().appdir(), 'Bitcoin')
            : BitcoinCore().datadir();

        // Always check for bitcoin.conf first - user config takes priority
        final bitcoinConfPath = path.join(confDir, 'bitcoin.conf');
        if (File(bitcoinConfPath).existsSync()) {
          return bitcoinConfPath;
        }

        // Use master config file in BitWindow directory (source of truth)
        // A read-only copy is also placed in the Bitcoin/Drivechain dir for inspection
        return path.join(BitWindow().rootDir(), kBitwindowBitcoinConfFilename);
      }(),
      _ => throw 'binary does not have a config file: $type',
    };
  }

  String logPath() {
    return switch (type) {
      BinaryType.BINARY_TYPE_BITCOIND => filePath([
        BitcoinCore().datadirNetwork(),
        'debug.log',
      ]),
      BinaryType.BINARY_TYPE_BITWINDOWD => filePath([datadirNetwork(), 'server.log']),
      BinaryType.BINARY_TYPE_THUNDER ||
      BinaryType.BINARY_TYPE_BITNAMES ||
      BinaryType.BINARY_TYPE_BITASSETS ||
      BinaryType.BINARY_TYPE_ZSIDE ||
      BinaryType.BINARY_TYPE_TRUTHCOIN ||
      BinaryType.BINARY_TYPE_PHOTON ||
      BinaryType.BINARY_TYPE_COINSHIFT => _findLatestDirVersionedLog(),
      BinaryType.BINARY_TYPE_ENFORCER => _findLatestEnforcerLog(),
      BinaryType.BINARY_TYPE_GRPCURL || BinaryType.BINARY_TYPE_ORCHESTRATORD || BinaryType.BINARY_TYPE_ZSIDED => '',
      BinaryType.BINARY_TYPE_UNSPECIFIED => _unsupportedBinaryType(type),
      _ => _unsupportedBinaryType(type),
    };
  }

  String _findLatestEnforcerLog() {
    final logsDir = Directory(filePath([datadirNetwork(), 'logs']));

    if (!logsDir.existsSync()) {
      return filePath([
        datadirNetwork(),
        'bip300301_enforcer.log',
      ]); // Fallback to original
    }

    // Find all enforcer log files matching the pattern: bip300301_enforcer.log.YYYY-MM-DD.N
    final logFiles = logsDir.listSync().whereType<File>().where((file) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      return fileName.startsWith('bip300301_enforcer.log.') &&
          RegExp(
            r'bip300301_enforcer\.log\.\d{4}-\d{2}-\d{2}\.\d+$',
          ).hasMatch(fileName);
    }).toList();

    if (logFiles.isEmpty) {
      return filePath([
        datadirNetwork(),
        'bip300301_enforcer.log',
      ]); // Fallback to original
    }

    // Sort by date and sequence number (latest first)
    logFiles.sort((a, b) {
      final aFileName = a.path.split(Platform.pathSeparator).last;
      final bFileName = b.path.split(Platform.pathSeparator).last;

      // Extract date and sequence number from filename
      final aMatch = RegExp(
        r'bip300301_enforcer\.log\.(\d{4}-\d{2}-\d{2})\.(\d+)$',
      ).firstMatch(aFileName);
      final bMatch = RegExp(
        r'bip300301_enforcer\.log\.(\d{4}-\d{2}-\d{2})\.(\d+)$',
      ).firstMatch(bFileName);

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
    final logsDir = Directory(filePath([datadirNetwork(), 'logs']));
    if (!logsDir.existsSync()) {
      return filePath([datadirNetwork(), 'logs', 'unknown.log']);
    }

    // Get all version directories
    final versionDirs = logsDir
        .listSync()
        .whereType<Directory>()
        .where(
          (dir) => dir.path.split(Platform.pathSeparator).last.startsWith('v'),
        )
        .toList();

    if (versionDirs.isEmpty) {
      return filePath([
        datadirNetwork(),
        'logs',
        'unknown.log',
      ]); // Fallback if no version directories found
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
      return filePath([
        datadirNetwork(),
        'logs',
        'unknown.log',
      ]); // Fallback if no log files found
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
        if (type == BinaryType.BINARY_TYPE_BITCOIND) {
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

  /// Returns the root datadir for a specific network
  String rootDirNetwork(BitcoinNetwork network) {
    final subdir = directories.binary[network]?[OS.current];
    if (subdir == null || subdir.isEmpty) {
      throw 'unsupported operating system or network, subdir is empty: ${Platform.operatingSystem}';
    }
    return filePath([appdir(), subdir]);
  }

  /// Returns the root datadir using any network (for binaries where dir is same for all networks)
  /// Use during initialization before BitcoinConfProvider is available
  /// Throws if directories differ per network (use rootDir(network) instead)
  String rootDir() {
    final values = directories.binary.values.map((m) => m[OS.current]).toSet();
    if (values.length > 1) {
      throw 'rootDirDefault() called on $name but directories differ per network: $values. Use rootDir(network) instead.';
    }

    return rootDirNetwork(directories.binary.keys.first);
  }

  /// Returns the base datadir (respects custom datadir, no network subdir)
  String datadir() {
    final network = GetIt.I<BitcoinConfProvider>().network;

    switch (type) {
      case BinaryType.BINARY_TYPE_BITCOIND:
        final provider = GetIt.I<BitcoinConfProvider>();
        return (provider.detectedDataDir?.isNotEmpty == true) ? provider.detectedDataDir! : rootDirNetwork(network);

      case BinaryType.BINARY_TYPE_ENFORCER:
        final provider = GetIt.I<EnforcerConfProvider>();
        final customDir = provider.currentConfig?.getSetting('datadir');
        return customDir ?? rootDir();

      case BinaryType.BINARY_TYPE_THUNDER:
      case BinaryType.BINARY_TYPE_BITNAMES:
      case BinaryType.BINARY_TYPE_BITASSETS:
      case BinaryType.BINARY_TYPE_ZSIDE:
      case BinaryType.BINARY_TYPE_TRUTHCOIN:
      case BinaryType.BINARY_TYPE_PHOTON:
      case BinaryType.BINARY_TYPE_COINSHIFT:
      case BinaryType.BINARY_TYPE_LIQUID_SIGNET:
        if (GetIt.I.isRegistered<GenericSidechainConfProvider>()) {
          final provider = GetIt.I<GenericSidechainConfProvider>();
          final customDir = provider.currentConfig?.getSetting('datadir');
          if (customDir != null) return customDir;
        }
        return rootDir();

      case BinaryType.BINARY_TYPE_BITWINDOWD:
        return rootDir();

      case BinaryType.BINARY_TYPE_GRPCURL:
      case BinaryType.BINARY_TYPE_ORCHESTRATORD:
      case BinaryType.BINARY_TYPE_ZSIDED:
        return rootDir();

      case BinaryType.BINARY_TYPE_UNSPECIFIED:
      default:
        throw StateError('unsupported BinaryType: $type');
    }
  }

  /// Returns the network-aware datadir (base + network subdir when needed)
  String datadirNetwork() {
    final network = GetIt.I<BitcoinConfProvider>().network;
    final baseDir = datadir();

    switch (type) {
      case BinaryType.BINARY_TYPE_BITCOIND:
        if (network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET ||
            network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
            network == BitcoinNetwork.BITCOIN_NETWORK_DRYNET2) {
          return baseDir;
        }
        return path.join(baseDir, network.toReadableNet());

      case BinaryType.BINARY_TYPE_BITWINDOWD:
        return path.join(baseDir, network.toReadableNet());

      case BinaryType.BINARY_TYPE_ENFORCER:
      case BinaryType.BINARY_TYPE_THUNDER:
      case BinaryType.BINARY_TYPE_BITNAMES:
      case BinaryType.BINARY_TYPE_BITASSETS:
      case BinaryType.BINARY_TYPE_ZSIDE:
      case BinaryType.BINARY_TYPE_TRUTHCOIN:
      case BinaryType.BINARY_TYPE_PHOTON:
      case BinaryType.BINARY_TYPE_COINSHIFT:
      case BinaryType.BINARY_TYPE_LIQUID_SIGNET:
      case BinaryType.BINARY_TYPE_GRPCURL:
      case BinaryType.BINARY_TYPE_ORCHESTRATORD:
      case BinaryType.BINARY_TYPE_ZSIDED:
        return baseDir;

      case BinaryType.BINARY_TYPE_UNSPECIFIED:
      default:
        throw StateError('unsupported BinaryType: $type');
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
  final Map<BitcoinNetwork, Map<OS, String>> binary;
  final Map<OS, String> flutterFrontend;

  const DirectoryConfig({required this.binary, required this.flutterFrontend});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DirectoryConfig && _mapEquals(binary, other.binary);

  @override
  int get hashCode => binary.hashCode;

  bool _mapEquals(
    Map<BitcoinNetwork, Map<OS, String>> a,
    Map<BitcoinNetwork, Map<OS, String>> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class DownloadConfig {
  final String binary;
  final Map<BitcoinNetwork, Map<OS, String>> files;
  final Map<BitcoinNetwork, Map<OS, String>>? extractSubfolder;
  final Map<BitcoinNetwork, String> _baseUrls;

  /// Per-OS download files keyed by variant id (e.g. 'core', 'patched',
  /// 'knots'). Only set for variant-aware binaries (Bitcoin Core); the active
  /// variant is chosen by the orchestrator and surfaced via CoreVariantProvider.
  final Map<String, Map<OS, String>> variants;

  const DownloadConfig({
    required this.binary,
    required this.files,
    this.extractSubfolder,
    this._baseUrls = const {},
    this.variants = const {},
  });

  /// Get the base URL for a network. Falls back to first available URL.
  String baseUrl([BitcoinNetwork? network]) {
    if (network != null && _baseUrls.containsKey(network)) {
      return _baseUrls[network]!;
    }
    return _baseUrls.isNotEmpty ? _baseUrls.values.first : '';
  }
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

  bool get hasAlternativeDownloadConfig => _alternativeDownloadConfig != null;

  DateTime? remoteTimestamp; // Last-Modified from server
  DateTime? downloadedTimestamp; // Local file timestamp
  File? binaryPath; // Path to the binary on disk (if exists)
  bool updateable; // Whether the binary can be updated

  MetadataConfig({
    required this._downloadConfig,
    this._alternativeDownloadConfig,
    required this.updateable,
    required this.remoteTimestamp,
    required this.downloadedTimestamp,
    required this.binaryPath,
  });

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
      alternativeConfigsEqual = _mapEquals(
        _alternativeDownloadConfig.files,
        other._alternativeDownloadConfig.files,
      );
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

  bool _mapEquals(
    Map<BitcoinNetwork, Map<OS, String>> a,
    Map<BitcoinNetwork, Map<OS, String>> b,
  ) {
    if (a.length != b.length) return false;
    for (final network in a.keys) {
      if (!b.containsKey(network)) return false;
      final aOsMap = a[network]!;
      final bOsMap = b[network]!;
      if (aOsMap.length != bOsMap.length) return false;
      for (final os in aOsMap.keys) {
        if (!bOsMap.containsKey(os) || aOsMap[os] != bOsMap[os]) return false;
      }
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
  final String? hash; // SHA256 of the downloaded archive
  final String? expectedHash; // SHA256 from hashes.json
  final bool? hashMatch; // null=unknown, true=verified, false=MISMATCH
  final DateTime? downloadedAt;
  final bool isDownloading;

  double get progressPercent => progress / total;

  const DownloadInfo({
    this.progress = 0.0,
    this.total = 0.0,
    this.error,
    this.message,
    this.hash,
    this.expectedHash,
    this.hashMatch,
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
    String? expectedHash,
    bool? hashMatch,
    DateTime? downloadedAt,
    bool? isDownloading,
  }) {
    return DownloadInfo(
      progress: progress ?? this.progress,
      total: total ?? this.total,
      error: error ?? this.error,
      message: message ?? this.message,
      hash: hash ?? this.hash,
      expectedHash: expectedHash ?? this.expectedHash,
      hashMatch: hashMatch ?? this.hashMatch,
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
          expectedHash == other.expectedHash &&
          hashMatch == other.hashMatch &&
          downloadedAt == other.downloadedAt &&
          isDownloading == other.isDownloading;

  @override
  @override
  int get hashCode => Object.hash(
    progress,
    total,
    error,
    hash,
    expectedHash,
    hashMatch,
    downloadedAt,
    isDownloading,
  );
}

class ProcessLogEntry {
  final DateTime timestamp;
  final String message;

  ProcessLogEntry({required this.timestamp, required this.message});
}

Map<BitcoinNetwork, Map<OS, String>> allNetworks(Map<OS, String> osFiles) {
  return {for (final network in BitcoinNetwork.values) network: osFiles};
}

Map<BitcoinNetwork, String> allNetworksUrl(String url) {
  return {for (final network in BitcoinNetwork.values) network: url};
}

/// Same value for all networks and all OS platforms.
Map<BitcoinNetwork, Map<OS, String>> allPlatforms(String value) {
  return allNetworks({OS.linux: value, OS.macos: value, OS.windows: value});
}

// JSON serialization helpers for chains_config.json

BitcoinNetwork _networkFromJsonKey(String key) {
  return switch (key) {
    'mainnet' => BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
    'regtest' => BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
    'signet' => BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
    'testnet' => BitcoinNetwork.BITCOIN_NETWORK_TESTNET,
    'forknet' => BitcoinNetwork.BITCOIN_NETWORK_FORKNET,
    'drynet2' => BitcoinNetwork.BITCOIN_NETWORK_DRYNET2,
    _ => BitcoinNetwork.BITCOIN_NETWORK_UNSPECIFIED, // 'default' key handled separately
  };
}

OS _osFromJsonKey(String key) {
  return switch (key) {
    'linux' => OS.linux,
    'macos' => OS.macos,
    'windows' => OS.windows,
    _ => throw ArgumentError('Unknown OS key: $key'),
  };
}

String colorToString(Color color) {
  if (color == SailColorScheme.green) return 'green';
  if (color == SailColorScheme.blue) return 'blue';
  if (color == SailColorScheme.purple) return 'purple';
  if (color == SailColorScheme.orange) return 'orange';
  return 'green';
}

/// Parse a directory map from JSON. The JSON uses "default" for all-networks
/// and specific network names for overrides.
Map<BitcoinNetwork, Map<OS, String>> _networkMapFromJson(
  Map<String, dynamic> json,
  Map<OS, String> Function(Map<String, dynamic>) leaf,
) {
  final result = <BitcoinNetwork, Map<OS, String>>{};

  // "default" key spreads to all networks
  if (json.containsKey('default')) {
    final defaultMap = leaf(json['default'] as Map<String, dynamic>);
    for (final network in BitcoinNetwork.values) {
      result[network] = Map.of(defaultMap);
    }
  }

  // Override specific networks
  for (final entry in json.entries) {
    if (entry.key == 'default') continue;
    final network = _networkFromJsonKey(entry.key);
    result[network] = leaf(entry.value as Map<String, dynamic>);
  }

  return result;
}

Map<BitcoinNetwork, Map<OS, String>> _directoryBinaryFromJson(Map<String, dynamic> json) =>
    _networkMapFromJson(json, _osMapFromJson);

/// Parse an OS-keyed (`linux`/`macos`/`windows`) leaf map. Used for directory
/// and extract-subfolder maps, which are CPU-arch independent.
Map<OS, String> _osMapFromJson(Map<String, dynamic> json) {
  return {
    for (final entry in json.entries)
      if (entry.key == 'linux' || entry.key == 'macos' || entry.key == 'windows')
        _osFromJsonKey(entry.key): entry.value as String,
  };
}

String _osJsonKey(OS os) => switch (os) {
  OS.linux => 'linux',
  OS.macos => 'macos',
  OS.windows => 'windows',
};

/// The running machine's CPU architecture token used in os-arch download keys.
String currentArch() => Abi.current().toString().toLowerCase().contains('arm64') ? 'arm64' : 'x86_64';

// CPU arch only varies for the OS we're running on; other OSes default to x86_64.
String _archForOS(OS os) => os == getOS() ? currentArch() : 'x86_64';

/// Resolves the download filename for [os]/[arch] from a raw os-arch keyed JSON
/// map (e.g. `macos-arm64`). Direct lookup — every platform is spelled out
/// explicitly in the config, so there is no fallback substitution.
String? fileForPlatform(Map<String, dynamic> json, OS os, String arch) {
  final file = json['${_osJsonKey(os)}-$arch'];
  return file is String && file.isNotEmpty ? file : null;
}

/// Parse an os-arch-keyed download `files` leaf into an OS-keyed map holding
/// the arch-correct filename for the running machine.
Map<OS, String> _platformMapFromJson(Map<String, dynamic> json) {
  final result = <OS, String>{};
  for (final os in OS.values) {
    final file = fileForPlatform(json, os, _archForOS(os));
    if (file != null && file.isNotEmpty) result[os] = file;
  }
  return result;
}

/// Parse a download `files` block (arch-aware leaf, network-spread).
Map<BitcoinNetwork, Map<OS, String>> _platformFilesFromJson(Map<String, dynamic> json) =>
    _networkMapFromJson(json, _platformMapFromJson);

/// Parse an OS-keyed network map (e.g. `extract_subfolder`).
Map<BitcoinNetwork, Map<OS, String>> _filesFromJson(Map<String, dynamic> json) => _directoryBinaryFromJson(json);

extension DirectoryConfigJson on DirectoryConfig {
  static DirectoryConfig fromJson(Map<String, dynamic> json) {
    return DirectoryConfig(
      binary: _directoryBinaryFromJson(json['binary'] as Map<String, dynamic>),
      flutterFrontend: _osMapFromJson(
        json['flutter_frontend'] as Map<String, dynamic>,
      ),
    );
  }
}

extension DownloadConfigJson on DownloadConfig {
  static DownloadConfig fromJson(Map<String, dynamic> json) {
    // `files` is absent for variant-aware binaries (bitcoincore), where the
    // per-OS download list lives under `download.variants.<id>.files`
    // instead. The orchestrator picks the active variant; the Dart side
    // resolves the matching files via CoreVariantProvider.activeId.
    final filesJson = json['files'] as Map<String, dynamic>? ?? const {};

    // Extract per-network base_url from files entries, or fall back to top-level base_url
    final topLevelBaseUrl = json['base_url'] as String?;
    final baseUrls = _baseUrlsFromFilesJson(filesJson, topLevelBaseUrl ?? '');

    final variantsJson = json['variants'] as Map<String, dynamic>? ?? const {};
    final variants = <String, Map<OS, String>>{
      for (final entry in variantsJson.entries)
        entry.key: _platformMapFromJson(
          (entry.value as Map<String, dynamic>)['files'] as Map<String, dynamic>? ?? const {},
        ),
    };

    return DownloadConfig(
      baseUrls: baseUrls,
      binary: json['binary'] as String,
      files: _platformFilesFromJson(filesJson),
      extractSubfolder: json.containsKey('extract_subfolder') && json['extract_subfolder'] != null
          ? _filesFromJson(json['extract_subfolder'] as Map<String, dynamic>)
          : null,
      variants: variants,
    );
  }
}

/// Extract base_url from each network entry in files JSON.
/// Each network entry can have its own "base_url" key.
/// Falls back to [defaultBaseUrl] if not present.
Map<BitcoinNetwork, String> _baseUrlsFromFilesJson(
  Map<String, dynamic> filesJson,
  String defaultBaseUrl,
) {
  final result = <BitcoinNetwork, String>{};

  for (final entry in filesJson.entries) {
    final networkMap = entry.value as Map<String, dynamic>;
    final url = networkMap['base_url'] as String? ?? defaultBaseUrl;

    if (entry.key == 'default') {
      for (final network in BitcoinNetwork.values) {
        result[network] = url;
      }
    } else {
      result[_networkFromJsonKey(entry.key)] = url;
    }
  }

  return result;
}

BinaryType _binaryTypeFromJsonKey(String key) {
  return switch (key) {
    'bitcoincore' => BinaryType.BINARY_TYPE_BITCOIND,
    'bitwindow' => BinaryType.BINARY_TYPE_BITWINDOWD,
    'enforcer' => BinaryType.BINARY_TYPE_ENFORCER,
    'grpcurl' => BinaryType.BINARY_TYPE_GRPCURL,
    'orchestratord' => BinaryType.BINARY_TYPE_ORCHESTRATORD,
    'zsided' => BinaryType.BINARY_TYPE_ZSIDED,
    'thunder' => BinaryType.BINARY_TYPE_THUNDER,
    'bitnames' => BinaryType.BINARY_TYPE_BITNAMES,
    'bitassets' => BinaryType.BINARY_TYPE_BITASSETS,
    'truthcoin' => BinaryType.BINARY_TYPE_TRUTHCOIN,
    'photon' => BinaryType.BINARY_TYPE_PHOTON,
    'coinshift' => BinaryType.BINARY_TYPE_COINSHIFT,
    'liquid-signet' => BinaryType.BINARY_TYPE_LIQUID_SIGNET,
    'zside' => BinaryType.BINARY_TYPE_ZSIDE,
    _ => throw ArgumentError('Unknown binary key: $key'),
  };
}

String binaryTypeToJsonKey(BinaryType type) {
  return switch (type) {
    BinaryType.BINARY_TYPE_BITCOIND => 'bitcoincore',
    BinaryType.BINARY_TYPE_BITWINDOWD => 'bitwindow',
    BinaryType.BINARY_TYPE_ENFORCER => 'enforcer',
    BinaryType.BINARY_TYPE_GRPCURL => 'grpcurl',
    BinaryType.BINARY_TYPE_ORCHESTRATORD => 'orchestratord',
    BinaryType.BINARY_TYPE_ZSIDED => 'zsided',
    BinaryType.BINARY_TYPE_THUNDER => 'thunder',
    BinaryType.BINARY_TYPE_BITNAMES => 'bitnames',
    BinaryType.BINARY_TYPE_BITASSETS => 'bitassets',
    BinaryType.BINARY_TYPE_TRUTHCOIN => 'truthcoin',
    BinaryType.BINARY_TYPE_PHOTON => 'photon',
    BinaryType.BINARY_TYPE_COINSHIFT => 'coinshift',
    BinaryType.BINARY_TYPE_LIQUID_SIGNET => 'liquid-signet',
    BinaryType.BINARY_TYPE_ZSIDE => 'zside',
    BinaryType.BINARY_TYPE_UNSPECIFIED => _unsupportedBinaryType(type),
    _ => _unsupportedBinaryType(type),
  };
}

/// Build a Binary from a JSON config entry.
/// [key] is the JSON key (e.g. "thunder"), [json] is the entry object.
Binary binaryFromJson(String key, Map<String, dynamic> json) {
  final binaryType = _binaryTypeFromJsonKey(key);

  final directories = DirectoryConfigJson.fromJson(
    json['directories'] as Map<String, dynamic>,
  );
  final downloadJson = json['download'] as Map<String, dynamic>;
  final downloadConfig = DownloadConfigJson.fromJson(downloadJson);

  DownloadConfig? altDownloadConfig;
  if (json.containsKey('alternative_download') && json['alternative_download'] != null) {
    altDownloadConfig = DownloadConfigJson.fromJson(
      json['alternative_download'] as Map<String, dynamic>,
    );
  }

  final metadata = MetadataConfig(
    downloadConfig: downloadConfig,
    alternativeDownloadConfig: altDownloadConfig,
    remoteTimestamp: null,
    downloadedTimestamp: null,
    binaryPath: null,
    updateable: false,
  );

  final name = json['name'] as String;
  final version = json['version'] as String;
  final description = json['description'] as String;
  final repoUrl = json['repo_url'] as String;
  final port = json['port'] as int;
  final chainLayer = json['chain_layer'] as int;

  // Dispatch to correct subclass
  return switch (binaryType) {
    BinaryType.BINARY_TYPE_BITCOIND => BitcoinCore(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_BITWINDOWD => BitWindow(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_ENFORCER => Enforcer(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_GRPCURL => GRPCurl(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_ORCHESTRATORD => Orchestratord(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_ZSIDED => ZSided(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_THUNDER => Thunder(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_BITNAMES => BitNames(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_BITASSETS => BitAssets(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_TRUTHCOIN => Truthcoin(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_PHOTON => Photon(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_COINSHIFT => CoinShift(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_LIQUID_SIGNET => LiquidSignet(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_ZSIDE => ZSide(
      name: name,
      version: version,
      description: description,
      repoUrl: repoUrl,
      directories: directories,
      metadata: metadata,
      port: port,
      chainLayer: chainLayer,
    ),
    BinaryType.BINARY_TYPE_UNSPECIFIED => _unsupportedBinaryType(binaryType),
    _ => _unsupportedBinaryType(binaryType),
  };
}
