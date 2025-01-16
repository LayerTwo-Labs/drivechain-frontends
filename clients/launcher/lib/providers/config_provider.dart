import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';

/// Service responsible for loading and managing chain configurations
class ConfigProvider {
  late List<Binary> _configs;
  final String _baseDir;

  List<Binary> get configs => _configs;

  ConfigProvider({
    String? baseDir,
  }) : _baseDir = baseDir ?? _defaultBaseDir;

  // Get the default base directory based on platform
  static String get _defaultBaseDir {
    if (Platform.isWindows) {
      return path.join(Platform.environment['APPDATA']!, 'Drivechain');
    } else if (Platform.isMacOS) {
      return path.join(
        Platform.environment['HOME']!,
        'Library',
        'Application Support',
        'Drivechain',
      );
    } else {
      // Linux and others
      return path.join(
        Platform.environment['HOME']!,
        '.drivechain',
      );
    }
  }

  /// Initialize configuration service
  Future<void> initialize() async {
    // Load chain configurations from assets
    final jsonString = await rootBundle.loadString('assets/chain_config.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> chainsJson = jsonData['chains'] as List<dynamic>;
    _configs = chainsJson.map((json) => Binary.fromJson(json as Map<String, dynamic>)).toList();

    // Ensure base directory exists
    await Directory(_baseDir).create(recursive: true);

    // Initialize component directories
    await _initializeDirectories();
  }

  /// Initialize directories for all components
  Future<void> _initializeDirectories() async {
    for (final chain in _configs) {
      final platform = _getPlatformKey();
      final baseDir = chain.directories.base[platform];
      if (baseDir != null) {
        final dir = path.join(_baseDir, baseDir);
        await Directory(dir).create(recursive: true);
      }
    }
  }

  /// Get chain configuration by binary name
  Binary? getChainConfig(String binaryName) {
    try {
      return _configs.firstWhere((chain) => chain.binary == binaryName);
    } catch (e) {
      return null;
    }
  }

  /// Get all L1 chain configurations
  List<Binary> getL1Chains() {
    return _configs.where((chain) => chain.chainLayer == 1).toList();
  }

  /// Get all L2 chain configurations
  List<Binary> getL2Chains() {
    return _configs.where((chain) => chain.chainLayer == 2).toList();
  }

  /// Get binary path for a component
  String? getBinaryPath(String binaryName) {
    final config = getChainConfig(binaryName);
    if (config == null) return null;

    final platform = _getPlatformKey();
    final baseDir = config.directories.base[platform];

    if (baseDir == null) return null;

    return path.join(_baseDir, baseDir, config.binary);
  }

  /// Get data directory for a component
  String? getDataDir(String binaryName) {
    final config = getChainConfig(binaryName);
    if (config == null) return null;

    final platform = _getPlatformKey();
    final baseDir = config.directories.base[platform];
    if (baseDir == null) return null;

    return path.join(_baseDir, baseDir);
  }

  /// Get wallet path for a component
  String? getWalletPath(String binaryName) {
    final config = getChainConfig(binaryName);
    if (config == null) return null;

    final platform = _getPlatformKey();
    final baseDir = config.directories.base[platform];

    if (baseDir == null) return null;

    return path.join(_baseDir, baseDir, 'wallet');
  }

  /// Gets the platform-specific key used in config
  OS _getPlatformKey() {
    if (Platform.isWindows) {
      return OS.windows;
    }
    if (Platform.isMacOS) {
      return OS.macos;
    }
    if (Platform.isLinux) {
      return OS.linux;
    }
    throw Exception('Unsupported platform');
  }
}
