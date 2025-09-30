import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

/// Provider for Bitcoin Core configuration settings integration.
/// Handles detection of bitcoin.conf (user) vs bitwindow-bitcoin.conf (generated) files.
/// Provides network and datadir settings for the settings page.
class BitcoinConfProvider extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();

  // File watching and management
  StreamSubscription<FileSystemEvent>? _fileWatcher;
  Timer? _fileWatchDebouncer;

  // Config file state
  bool _hasPrivateBitcoinConf = false;
  String? _currentConfigPath;
  Network _detectedNetwork = Network.NETWORK_MAINNET;
  String? _detectedDataDir;
  BitcoinConfig? _currentConfig;

  // Getters for settings integration
  bool get hasPrivateBitcoinConf => _hasPrivateBitcoinConf;
  Network get network {
    return _detectedNetwork;
  }

  String? get detectedDataDir => _detectedDataDir;
  bool get canEditNetwork => !_hasPrivateBitcoinConf;
  String get currentConfigFile => _hasPrivateBitcoinConf ? 'bitcoin.conf' : 'bitwindow-bitcoin.conf';

  /// Get the actual RPC port being used (respects user's rpcport setting)
  int get rpcPort {
    if (_currentConfig != null) {
      final rpcPortSetting = _currentConfig!.getSetting('rpcport');
      if (rpcPortSetting != null) {
        final customPort = int.tryParse(rpcPortSetting);
        if (customPort != null) {
          return customPort;
        }
      }
    }

    // Fall back to network defaults if no custom port set
    return switch (_detectedNetwork) {
      Network.NETWORK_MAINNET => 8332,
      Network.NETWORK_TESTNET => 18332,
      Network.NETWORK_SIGNET => 38332,
      Network.NETWORK_REGTEST => 18443,
      _ => 38332, // fallback to signet
    };
  }

  // Private constructor
  BitcoinConfProvider._create();

  // Async factory
  static Future<BitcoinConfProvider> create() async {
    final instance = BitcoinConfProvider._create();
    await instance.loadConfig(); // Load config synchronously during initialization
    return instance;
  }

  @override
  void dispose() {
    _fileWatcher?.cancel();
    _fileWatchDebouncer?.cancel();
    super.dispose();
  }

  Future<void> loadConfig() async {
    try {
      // Determine which config file to use
      final confInfo = _getConfigFileInfo();
      _hasPrivateBitcoinConf = confInfo.hasPrivateConf;
      _currentConfigPath = confInfo.path;

      // Load the active config file
      final file = File(confInfo.path);
      String content = '';
      if (await file.exists()) {
        content = await file.readAsString();
      } else {
        // Use the default config if no file exists
        content = _defaultConf();

        // Write default config to disk if we're using bitwindow-bitcoin.conf (not user bitcoin.conf)
        if (!_hasPrivateBitcoinConf) {
          try {
            // Ensure the directory exists
            await file.parent.create(recursive: true);
            await file.writeAsString(content);
            log.i('Created default config file: ${file.path}');
          } catch (e) {
            log.e('Failed to write default config file: $e');
          }
        }
      }

      // Parse config to detect settings
      _currentConfig = BitcoinConfig.parse(content);

      // Extract network and datadir from the config
      _detectNetworkFromConfig();
      _detectDataDirFromConfig();

      // Set up file watching
      _setupFileWatching();

      // Update MainchainRPC configuration on initial load
      _updateMainchainRPCConfig(_createConnectionSettings());

      notifyListeners();
    } catch (e) {
      log.e('Failed to load config: $e');
    }
  }

  /// Update network setting - only allowed when using bitwindow-bitcoin.conf
  Future<void> updateNetwork(Network network) async {
    if (_hasPrivateBitcoinConf) {
      log.w('Cannot update network - controlled by user bitcoin.conf');
      return;
    }

    if (_currentConfig == null) return;

    // Clear any existing network settings
    _currentConfig!.globalSettings.remove('chain');
    _currentConfig!.globalSettings.remove('testnet');
    _currentConfig!.globalSettings.remove('testnet4');
    _currentConfig!.globalSettings.remove('signet');
    _currentConfig!.globalSettings.remove('regtest');

    // Set the new network
    switch (network) {
      case Network.NETWORK_MAINNET:
        _currentConfig!.setSetting('chain', 'main');
        break;
      case Network.NETWORK_TESTNET:
        _currentConfig!.setSetting('chain', 'test');
        break;
      case Network.NETWORK_SIGNET:
        _currentConfig!.setSetting('chain', 'signet');
        break;
      case Network.NETWORK_REGTEST:
        _currentConfig!.setSetting('chain', 'regtest');
        break;
      case Network.NETWORK_UNKNOWN:
      case Network.NETWORK_UNSPECIFIED:
        // Use mainnet as default for unknown/unspecified networks
        _currentConfig!.setSetting('chain', 'main');
        break;
    }

    _detectedNetwork = network;

    // Save the config
    await _saveConfig();

    _updateMainchainRPCConfig(_createConnectionSettings());

    notifyListeners();
  }

  /// Restart all services when mainnet toggle changes
  Future<void> restartServicesForMainnet() async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final binaries = [
      BitcoinCore(),
      Enforcer(),
      BitWindow(),
    ];

    log.i('Stopping core, enforcer, and bitwindow...');
    final stopFutures = <Future>[];
    for (final binary in binaries) {
      stopFutures.add(binaryProvider.stop(binary));
    }
    await Future.wait(stopFutures);

    // Delete enforcer and bitwindow data
    log.i('Deleting enforcer and bitwindow data...');
    final enforcer = Enforcer();
    final bitwindow = BitWindow();
    await Future.wait([
      enforcer.wipeAppDir(),
      bitwindow.wipeAppDir(),
    ]);

    // Update MainchainRPC configuration with new network settings
    final newConf = readMainchainConf();
    _updateMainchainRPCConfig(newConf);

    // Restart all services
    log.i('Restarting services...');
    final bitwindowBinary = binaryProvider.binaries.firstWhere((b) => b is BitWindow);
    await binaryProvider.startWithEnforcer(
      bitwindowBinary,
      bootExtraBinaryImmediately: true,
    );

    log.i('Service restart completed');
  }

  /// Restart services with detailed progress updates for UI
  Future<void> restartServicesWithProgress(void Function(String) updateStatus) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final binaries = [
      BitcoinCore(),
      Enforcer(),
      BitWindow(),
    ];

    // Stop all services
    updateStatus('Stopping Bitcoin Core');
    await binaryProvider.stop(binaries[0]);

    updateStatus('Stopping Enforcer');
    await binaryProvider.stop(binaries[1]);

    updateStatus('Stopping BitWindow');
    await binaryProvider.stop(binaries[2]);

    updateStatus('Waiting for processes to exit');
    // The binary provider's stop() already waits for PIDs to die, so this is informational

    updateStatus('Updating bitcoin.conf');
    // Config already updated by updateNetwork() before this is called

    // Delete enforcer and bitwindow data
    updateStatus('Cleaning enforcer data');
    final enforcer = Enforcer();
    await enforcer.wipeAppDir();

    updateStatus('Cleaning bitwindow data');
    final bitwindow = BitWindow();
    await bitwindow.wipeAppDir();

    // Update MainchainRPC configuration with new network settings
    final newConf = readMainchainConf();
    _updateMainchainRPCConfig(newConf);

    // Restart all services
    updateStatus('Starting Bitcoin Core');
    final bitwindowBinary = binaryProvider.binaries.firstWhere((b) => b is BitWindow);

    updateStatus('Starting Enforcer');
    // startWithEnforcer handles both enforcer and bitwindow

    updateStatus('Starting BitWindow');
    await binaryProvider.startWithEnforcer(
      bitwindowBinary,
      bootExtraBinaryImmediately: true,
    );

    updateStatus('Network swap complete');
    log.i('Service restart completed');
  }

  /// Update datadir
  Future<void> updateDataDir(String? dataDir) async {
    if (_hasPrivateBitcoinConf) {
      log.w('Cannot update datadir - controlled by your private bitcoin.conf');
      return;
    }

    if (_currentConfig == null) return;

    if (dataDir == null || dataDir.isEmpty) {
      _currentConfig!.removeSetting('datadir');
    } else {
      _currentConfig!.setSetting('datadir', dataDir);
      _detectedDataDir = dataDir;
    }

    // Save the config
    await _saveConfig();
  }

  // Private helper methods

  Future<void> _saveConfig() async {
    if (_currentConfig == null) return;
    if (_hasPrivateBitcoinConf) {
      log.w('Cannot save - user bitcoin.conf takes precedence');
      return;
    }

    try {
      final confFile = _getConfigFileInfo();
      final file = File(confFile.path);

      // Write new config
      await file.writeAsString(_currentConfig!.serialize());
      log.i('Saved config to $confFile');
      notifyListeners();
    } catch (e) {
      log.e('Failed to save config: $e');
    }
  }

  ({bool hasPrivateConf, String path}) _getConfigFileInfo() {
    final datadir = BitcoinCore().datadir();

    if (BitcoinCore().confFile() == 'bitcoin.conf') {
      return (hasPrivateConf: true, path: path.join(datadir, 'bitcoin.conf'));
    }

    // Fall back to our generated config
    final bitwindowConfPath = path.join(datadir, 'bitwindow-bitcoin.conf');
    return (hasPrivateConf: false, path: bitwindowConfPath);
  }

  void _detectNetworkFromConfig() {
    if (_currentConfig == null) return;

    // Check for chain= setting first (preferred)
    final chainSetting = _currentConfig!.getSetting('chain');
    if (chainSetting != null) {
      switch (chainSetting.toLowerCase()) {
        case 'main':
        case 'mainnet':
          _detectedNetwork = Network.NETWORK_MAINNET;
          return;
        case 'test':
        case 'testnet':
          _detectedNetwork = Network.NETWORK_TESTNET;
          return;
        case 'signet':
          _detectedNetwork = Network.NETWORK_SIGNET;
          return;
        case 'regtest':
          _detectedNetwork = Network.NETWORK_REGTEST;
          return;
      }
    }

    // Check for legacy boolean flags
    if (_currentConfig!.getSetting('testnet') == '1') {
      _detectedNetwork = Network.NETWORK_TESTNET;
      return;
    }
    if (_currentConfig!.getSetting('signet') == '1') {
      _detectedNetwork = Network.NETWORK_SIGNET;
      return;
    }
    if (_currentConfig!.getSetting('regtest') == '1') {
      _detectedNetwork = Network.NETWORK_REGTEST;
      return;
    }

    // Default to mainnet if no network specified
    _detectedNetwork = Network.NETWORK_MAINNET;
  }

  void _detectDataDirFromConfig() {
    if (_currentConfig == null) return;
    _detectedDataDir ??= _currentConfig!.getSetting('datadir');
  }

  void _setupFileWatching() {
    // Cancel existing watcher
    _fileWatcher?.cancel();

    try {
      final datadir = BitcoinCore().datadir();
      final datadirObj = Directory(datadir);

      // Watch the entire datadir for config file changes
      _fileWatcher = datadirObj
          .watch(events: FileSystemEvent.modify | FileSystemEvent.create | FileSystemEvent.delete)
          .where((event) => event.path.endsWith('.conf'))
          .listen(_handleFileSystemEvent);

      log.d('File watching enabled for $datadir');
    } catch (e) {
      log.e('Failed to setup file watching: $e');
    }
  }

  void _handleFileSystemEvent(FileSystemEvent event) {
    final fileName = path.basename(event.path);
    if (fileName == 'bitcoin.conf' || fileName == 'bitwindow-bitcoin.conf') {
      log.d('Config file changed: ${event.path}');

      // Debounce file changes to avoid rapid reloads
      _fileWatchDebouncer?.cancel();
      _fileWatchDebouncer = Timer(const Duration(milliseconds: 500), () {
        _reloadConfigFromFileSystem();
      });
    }
  }

  void _reloadConfigFromFileSystem() async {
    try {
      log.i('Reloading config due to file system change');

      // Check if the controlling config file has changed
      final confInfo = _getConfigFileInfo();
      final hadUserConf = _hasPrivateBitcoinConf;
      _hasPrivateBitcoinConf = confInfo.hasPrivateConf;

      // If the controlling file changed (e.g., user created bitcoin.conf), reload everything
      if (hadUserConf != _hasPrivateBitcoinConf || confInfo.path != _currentConfigPath) {
        await loadConfig();
        return;
      }

      // Otherwise just reload the current config content
      final file = File(confInfo.path);
      if (await file.exists()) {
        final content = await file.readAsString();
        final newConfig = BitcoinConfig.parse(content);

        // Update config if content actually changed
        if (newConfig != _currentConfig) {
          _currentConfig = newConfig;
          _detectNetworkFromConfig();
          _detectDataDirFromConfig();

          // Update MainchainRPC configuration when config changes
          _updateMainchainRPCConfig(_createConnectionSettings());

          notifyListeners();
        }
      }
    } catch (e) {
      log.e('Failed to reload config from file system: $e');
    }
  }

  /// Get the default configuration content
  String getDefaultConfig() {
    return '''# Generated code. Any changes to this file *will* get overwritten.
# source: bitwindow bitcoin config settings

# Common settings for all networks
rpcuser=user
rpcpassword=password
server=1
listen=1
txindex=1
zmqpubsequence=tcp://0.0.0.0:29000
rpcthreads=20
rpcworkqueue=100
rest=1
fallbackfee=0.00021
chain=signet

# [Sections]
# Most options automatically apply to mainnet, testnet,
# and regtest.

# If you want to confine an option to just one network,
# you should add it in the relevant section.

# EXCEPTIONS: The options addnode, connect, port, bind,
# rpcport, rpcbind and wallet
# only apply to mainnet unless they appear in the
# appropriate section below.

# Mainnet-specific settings
[main]

# Testnet-specific settings
[test]

# Signet-specific settings
[signet]
addnode=172.105.148.135:38333
signetblocktime=60
signetchallenge=00141551188e5153533b4fdd555449e640d9cc129456
acceptnonstdtxn=1

# Regtest-specific settings
[regtest]
''';
  }

  /// Get the current configuration content as string
  String getCurrentConfigContent() {
    if (_currentConfig == null) {
      return getDefaultConfig();
    }
    return _currentConfig!.serialize();
  }

  /// Write configuration content to the appropriate file
  Future<void> writeConfig(String content) async {
    if (_hasPrivateBitcoinConf) {
      log.w('Cannot write config - user bitcoin.conf takes precedence');
      return;
    }

    try {
      final config = BitcoinConfig.parse(content);
      _currentConfig = config;

      final confFile = _getConfigFileInfo();
      final file = File(confFile.path);
      await file.writeAsString(content);

      log.i('Saved config to $confFile');

      // Update detected network and datadir
      _detectNetworkFromConfig();
      _detectDataDirFromConfig();

      notifyListeners();
    } catch (e) {
      log.e('Failed to write config: $e');
      rethrow;
    }
  }

  String _defaultConf() {
    return getDefaultConfig();
  }

  /// Update MainchainRPC configuration when config changes
  void _updateMainchainRPCConfig(CoreConnectionSettings newConf) {
    try {
      final mainchainRPC = GetIt.I.get<MainchainRPC>();
      mainchainRPC.updateConf(newConf);
      log.i('Updated MainchainRPC configuration: ${newConf.host}:${newConf.port}');

      // Also update the Binary's port to keep it in sync
      try {
        final binaryProvider = GetIt.I.get<BinaryProvider>();
        binaryProvider.updateBinary(
          BinaryType.bitcoinCore,
          (binary) => binary.copyWith(port: newConf.port),
        );
        log.i('Updated Bitcoin Core binary port to ${newConf.port}');
      } catch (e) {
        log.w('Could not update Bitcoin Core binary port: $e');
      }
    } catch (e) {
      log.w('Could not update MainchainRPC configuration: $e');
    }
  }

  /// Create CoreConnectionSettings from the current parsed config
  CoreConnectionSettings _createConnectionSettings() {
    final confInfo = _getConfigFileInfo();

    // Get connection settings from current config
    String host = '127.0.0.1';
    String username = 'user';
    String password = 'password';

    if (_currentConfig != null) {
      host = _currentConfig!.getSetting('rpcconnect') ?? _currentConfig!.getSetting('rpchost') ?? host;
      username = _currentConfig!.getSetting('rpcuser') ?? username;
      password = _currentConfig!.getSetting('rpcpassword') ?? password;
    }

    return CoreConnectionSettings.fromParsedConfig(
      confPath: confInfo.path,
      host: host,
      port: rpcPort, // Use the getter which already handles network-specific logic
      username: username,
      password: password,
      network: _detectedNetwork,
      configValues: _currentConfig?.globalSettings ?? {},
      configFromFile: _currentConfig?.globalSettings.keys.toSet() ?? {},
    );
  }
}
