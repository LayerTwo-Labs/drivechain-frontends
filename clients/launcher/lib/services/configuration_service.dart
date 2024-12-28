import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import '../models/chain_config.dart';

/// Service responsible for loading and managing chain configurations
class ConfigurationService {
  late ChainConfigs _configs;
  final String _baseDir;
  
  ChainConfigs get configs => _configs;
  
  ConfigurationService({String? baseDir}) : _baseDir = baseDir ?? _defaultBaseDir;

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
    _configs = ChainConfigs.fromJson(jsonData);
    
    // Ensure base directory exists
    await Directory(_baseDir).create(recursive: true);
    
    // Initialize component directories
    await _initializeDirectories();
  }

  /// Initialize directories for all components
  Future<void> _initializeDirectories() async {
    for (final chain in _configs.chains) {
      final platform = _getPlatformKey();
      final baseDir = chain.directories.base[platform];
      if (baseDir != null) {
        final dir = path.join(_baseDir, baseDir);
        await Directory(dir).create(recursive: true);
      }
    }
  }

  /// Get chain configuration by ID
  ChainConfig? getChainConfig(String id) {
    try {
      return _configs.chains.firstWhere((chain) => chain.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all L1 chain configurations
  List<ChainConfig> getL1Chains() {
    return _configs.chains.where((chain) => chain.chainType == 0).toList();
  }

  /// Get all L2 chain configurations
  List<ChainConfig> getL2Chains() {
    return _configs.chains.where((chain) => chain.chainType == 1).toList();
  }

  /// Get binary path for a component
  String? getBinaryPath(String componentId) {
    final config = getChainConfig(componentId);
    if (config == null) return null;

    final platform = _getPlatformKey();
    final baseDir = config.directories.base[platform];
    final binary = config.binary[platform];
    
    if (baseDir == null || binary == null) return null;
    
    return path.join(_baseDir, baseDir, binary);
  }

  /// Get data directory for a component
  String? getDataDir(String componentId) {
    final config = getChainConfig(componentId);
    if (config == null) return null;

    final platform = _getPlatformKey();
    final baseDir = config.directories.base[platform];
    if (baseDir == null) return null;
    
    return path.join(_baseDir, baseDir);
  }

  /// Get wallet path for a component
  String? getWalletPath(String componentId) {
    final config = getChainConfig(componentId);
    if (config == null) return null;

    final platform = _getPlatformKey();
    final baseDir = config.directories.base[platform];
    final walletPath = config.directories.wallet;
    
    if (baseDir == null || walletPath.isEmpty) return null;
    
    return path.join(_baseDir, baseDir, walletPath);
  }

  /// Gets the platform-specific key used in config
  String _getPlatformKey() {
    if (Platform.isWindows) return 'win32';
    if (Platform.isMacOS) return 'darwin';
    if (Platform.isLinux) return 'linux';
    throw Exception('Unsupported platform');
  }
}
