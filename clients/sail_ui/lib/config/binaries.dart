import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/style/color_scheme.dart';
import 'package:sail_ui/utils/file_utils.dart';

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

/// Configuration for component downloads
class DownloadConfig {
  final String baseUrl;
  final Map<OS, String> files;
  final Map<String, int>? sizes;
  final Map<String, String>? hashes;
  final DateTime? timestamp;

  const DownloadConfig({
    required this.baseUrl,
    required this.files,
    this.sizes,
    this.hashes,
    this.timestamp,
  });

  factory DownloadConfig.fromJson(Map<String, dynamic> json) {
    final timestampStr = json['timestamp'] as String?;
    return DownloadConfig(
      baseUrl: json['base_url'] as String,
      files: {
        OS.linux: (json['files'] as Map<String, dynamic>)['linux'] as String? ?? '',
        OS.macos: (json['files'] as Map<String, dynamic>)['darwin'] as String? ?? '',
        OS.windows: (json['files'] as Map<String, dynamic>)['win32'] as String? ?? '',
      },
      sizes: (json['sizes'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as int),
      ),
      hashes: (json['hashes'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
      timestamp: timestampStr != null ? DateTime.parse(timestampStr) : null,
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
  final String hash; // SHA256 of the binary
  final DateTime releaseDate; // Last-Modified date from server

  const DownloadMetadata({
    required this.hash,
    required this.releaseDate,
  });

  factory DownloadMetadata.fromJson(Map<String, dynamic> json) {
    return DownloadMetadata(
      hash: json['hash'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'hash': hash,
        'releaseDate': releaseDate.toIso8601String(),
      };
}

abstract class Binary {
  final String name;
  final String version;
  final String description;
  final String repoUrl;
  final DirectoryConfig directories;
  final DownloadConfig download;
  final String binary;
  final NetworkConfig network;
  final int chainLayer;

  const Binary({
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
      'Enforcer' => Enforcer(),
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
    super.chainLayer = 0,
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
          network: network ?? NetworkConfig(port: 38332),
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
          network: network ?? NetworkConfig(port: 38332),
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
    final binaryPath = path.join(datadir.path, 'assets', binary);
    final exists = await File(binaryPath).exists();
    return exists;
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
