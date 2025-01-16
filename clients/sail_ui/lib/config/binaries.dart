import 'dart:io';
import 'dart:ui';

import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/style/color_scheme.dart';

enum OS {
  linux,
  macos,
  windows;

  static OS get current {
    if (Platform.isLinux) return OS.linux;
    if (Platform.isMacOS) return OS.macos;
    if (Platform.isWindows) return OS.windows;
    throw 'unsupported operating system: ${Platform.operatingSystem}';
  }
}

/// Configuration for component directories
class DirectoryConfig {
  final Map<OS, String> base;

  const DirectoryConfig({
    required this.base,
  });

  factory DirectoryConfig.fromJson(Map<String, dynamic> json) {
    final baseJson = json['base'] as Map<String, dynamic>;
    return DirectoryConfig(
      base: {
        OS.linux: baseJson['linux'] as String? ?? '',
        OS.macos: baseJson['darwin'] as String? ?? '',
        OS.windows: baseJson['win32'] as String? ?? '',
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
      port: json['port'] as int,
    );
  }
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
    final binaryMap = json['binary'] as Map<String, dynamic>;
    final platform = Platform.operatingSystem;
    final binaryPath = switch (platform) {
      'linux' => binaryMap['linux'],
      'macos' => binaryMap['darwin'],
      'windows' => binaryMap['win32'],
      _ => throw Exception('unsupported platform')
    } as String;

    return _BinaryImpl(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      repoUrl: json['repo_url'] as String,
      directories: DirectoryConfig.fromJson(json['directories'] as Map<String, dynamic>),
      download: DownloadConfig.fromJson(json['download'] as Map<String, dynamic>),
      binary: binaryPath,
      network: NetworkConfig.fromJson(json['network'] as Map<String, dynamic>),
      chainLayer: json['chain_layer'] as int,
    );
  }
}

class ParentChain extends Binary {
  ParentChain()
      : super(
          name: 'Parent Chain',
          version: '0.1.0',
          description: 'Drivechain Parent Chain',
          repoUrl: 'https://github.com/drivechain-project/drivechain',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.drivechain',
              OS.macos: 'Drivechain',
              OS.windows: 'Drivechain',
            },
          ),
          download: DownloadConfig(
            baseUrl: 'https://releases.drivechain.info/',
            files: {
              OS.linux: 'L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu.zip',
              OS.macos: 'L1-bitcoin-patched-latest-x86_64-apple-darwin.zip',
              OS.windows: 'L1-bitcoin-patched-latest-x86_64-w64-msvc.zip',
            },
          ),
          binary: 'bitcoind',
          network: NetworkConfig(port: 38332),
          chainLayer: 1,
        );

  @override
  Color get color => SailColorScheme.green;
}

class BitWindow extends Binary {
  BitWindow()
      : super(
          name: 'BitWindow',
          version: '0.1.0',
          description: 'BitWindow UI',
          repoUrl: 'https://github.com/drivechain-project/bitwindow',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.bitwindow',
              OS.macos: 'bitwindow',
              OS.windows: 'bitwindow',
            },
          ),
          download: DownloadConfig(
            baseUrl: 'https://releases.drivechain.info/',
            files: {
              OS.linux: 'BitWindow-latest-x86_64-unknown-linux-gnu.zip',
              OS.macos: 'BitWindow-latest-x86_64-apple-darwin.zip',
              OS.windows: 'BitWindow-latest-x86_64-pc-windows-msvc.zip',
            },
          ),
          binary: 'bitwindowd',
          network: NetworkConfig(port: 38332),
          chainLayer: 0,
        );

  @override
  Color get color => SailColorScheme.green;
}

class Enforcer extends Binary {
  Enforcer()
      : super(
          name: 'Enforcer',
          version: '0.1.0',
          description: 'BIP300/301 Enforcer',
          repoUrl: 'https://github.com/drivechain-project/enforcer',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.enforcer',
              OS.macos: 'bip300301_enforcer',
              OS.windows: 'bip300301_enforcer',
            },
          ),
          download: DownloadConfig(
            baseUrl: 'https://releases.drivechain.info/',
            files: {
              OS.linux: 'bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip',
              OS.macos: 'bip300301-enforcer-latest-x86_64-apple-darwin.zip',
              OS.windows: 'bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip',
            },
          ),
          binary: 'bip300301_enforcer',
          network: NetworkConfig(port: 38332),
          chainLayer: 0,
        );

  @override
  Color get color => SailColorScheme.green;
}

extension BinaryPaths on Binary {
  String confFile() {
    switch (this) {
      case TestSidechain():
        return 'testchain.conf';
      case EthereumSidechain():
        return 'config.toml';
      case ZCashSidechain():
        return 'zcash.conf';
      case ParentChain():
        return 'bitcoin.conf';
      default:
        throw 'unsupported binary type: $runtimeType';
    }
  }

  String logDir() {
    switch (this) {
      case TestSidechain():
        return filePath([datadir(), 'debug.log']);
      case EthereumSidechain():
        return filePath([datadir(), 'ethereum.log']);
      case ZCashSidechain():
        return filePath([datadir(), 'regtest', 'debug.log']);
      case ParentChain():
        return filePath([datadir(), 'debug.log']);
      default:
        throw 'unsupported binary type: $runtimeType';
    }
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
}