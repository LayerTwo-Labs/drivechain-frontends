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
  BitcoinNetwork _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  String? _detectedDataDir;
  BitcoinConfig? _currentConfig;

  // Getters for settings integration
  bool get hasPrivateBitcoinConf => _hasPrivateBitcoinConf;
  BitcoinNetwork get network {
    return _detectedNetwork;
  }

  String? get detectedDataDir => _detectedDataDir;
  bool get canEditNetwork => !_hasPrivateBitcoinConf;
  String get currentConfigFile => _hasPrivateBitcoinConf ? 'bitcoin.conf' : 'bitwindow-bitcoin.conf';
  BitcoinConfig? get currentConfig => _currentConfig;

  /// Get the actual RPC port being used (respects user's rpcport setting from config + network section)
  int get rpcPort {
    if (_currentConfig != null) {
      // Get effective setting (network section overrides global)
      // Use toCoreNetworkForBitcoinSettings() for Bitcoin Core settings like rpcport
      final rpcPortSetting = _currentConfig!.getEffectiveSetting(
        'rpcport',
        _detectedNetwork.toCoreNetworkForBitcoinSettings(),
      );
      if (rpcPortSetting != null) {
        final customPort = int.tryParse(rpcPortSetting);
        if (customPort != null) {
          return customPort;
        }
      }
    }

    // Fall back to network defaults if no custom port set
    return switch (_detectedNetwork) {
      BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 8332, // real Bitcoin mainnet
      BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 18301, // forknet
      BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 18332,
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 38332,
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 18443,
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

      // Migrate legacy [forknet] section if present
      if (!_hasPrivateBitcoinConf) {
        await _migrateLegacyForknetSection(content);
      }

      // Extract network and datadir from the config
      _detectNetworkFromConfig();
      _detectDataDirFromConfig();

      // Save [main] section to network-specific file (bitwindow-bitcoin.conf is source of truth)
      await _syncMainSectionFile();

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
  Future<void> updateNetwork(BitcoinNetwork network) async {
    if (_hasPrivateBitcoinConf) {
      log.w('Cannot update network - controlled by user bitcoin.conf');
      return;
    }

    if (_currentConfig == null) return;

    final oldNetwork = _detectedNetwork;

    // Save current [main] section if leaving mainnet/forknet
    if (_isMainnetOrForknet(oldNetwork) && oldNetwork != network) {
      await _saveMainSectionForNetwork(oldNetwork);
    }

    // Load [main] section if entering mainnet/forknet
    if (_isMainnetOrForknet(network) && oldNetwork != network) {
      await _loadMainSectionForNetwork(network);
    }

    // Handle mainnet/forknet (both use [main] section)
    if (_isMainnetOrForknet(network)) {
      // Ensure [main] section exists
      _currentConfig!.networkSettings['main'] ??= {};

      // Update drivechain setting based on network
      if (network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
        _currentConfig!.networkSettings['main']!['drivechain'] = '1';
      } else {
        _currentConfig!.networkSettings['main']!.remove('drivechain');
      }

      // Set chain=main for mainnet/forknet
      _currentConfig!.setSetting('chain', 'main');

      _detectedNetwork = network;
    } else {
      // Switching to signet/testnet/regtest - just update chain setting
      _currentConfig!.removeSetting('testnet');
      _currentConfig!.removeSetting('testnet4');
      _currentConfig!.removeSetting('signet');
      _currentConfig!.removeSetting('regtest');

      switch (network) {
        case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
          _currentConfig!.setSetting('chain', 'test');
          break;
        case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
          _currentConfig!.setSetting('chain', 'signet');
          break;
        case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
          _currentConfig!.setSetting('chain', 'regtest');
          break;
        default:
          _currentConfig!.setSetting('chain', 'signet');
          break;
      }

      _detectedNetwork = network;
    }

    // Load datadir for the new network from its section
    _detectDataDirFromConfig();

    // Save the config
    await _saveConfig();

    _updateMainchainRPCConfig(_createConnectionSettings());

    notifyListeners();
  }

  /// Check if network is mainnet or forknet (both use main section)
  bool _isMainnetOrForknet(BitcoinNetwork network) {
    return network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET || network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET;
  }

  /// Restart services with detailed progress updates for UI
  Future<void> restartServicesWithProgress(BitcoinNetwork newNetwork, void Function(String) updateStatus) async {
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

    // Clear sync state from old network
    try {
      final syncProvider = GetIt.I.get<SyncProvider>();
      syncProvider.clearState();
      log.i('Cleared sync provider state');
    } catch (e) {
      log.w('Could not clear sync provider state: $e');
    }

    updateStatus('Updating bitcoin.conf');
    // Config already updated by updateNetwork() before this is called
    await updateNetwork(newNetwork);

    // Restart all services
    updateStatus('Starting Core, Enforcer and BitWindow');
    final bitwindowBinary = binaryProvider.binaries.firstWhere((b) => b is BitWindow);
    await binaryProvider.startWithEnforcer(
      bitwindowBinary,
      bootExtraBinaryImmediately: true,
    );

    updateStatus('Network swap complete');
    log.i('Service restart completed');
  }

  /// Update datadir for the specified network section (or current network if not specified)
  Future<void> updateDataDir(String? dataDir, {BitcoinNetwork? forNetwork}) async {
    if (_hasPrivateBitcoinConf) {
      log.w('Cannot update datadir - controlled by your private bitcoin.conf');
      return;
    }

    if (_currentConfig == null) return;

    // Use specified network or fall back to current detected network
    final targetNetwork = forNetwork ?? _detectedNetwork;
    final section = targetNetwork.toCoreNetwork();

    if (dataDir == null || dataDir.isEmpty) {
      _currentConfig!.removeSetting('datadir', section: section);
      // Only update _detectedDataDir if we're modifying the current network
      if (targetNetwork == _detectedNetwork) {
        _detectedDataDir = null;
      }
    } else {
      _currentConfig!.setSetting('datadir', dataDir, section: section);
      // Only update _detectedDataDir if we're modifying the current network
      if (targetNetwork == _detectedNetwork) {
        _detectedDataDir = dataDir;
      }
    }

    // Save the config file
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
    // Use network-specific datadir:
    // - MAINNET: ~/Library/Application Support/Bitcoin (standard Bitcoin Core)
    // - FORKNET/SIGNET/TESTNET/REGTEST: ~/Library/Application Support/Drivechain
    final datadir = _detectedNetwork == BitcoinNetwork.BITCOIN_NETWORK_MAINNET
        ? _getMainnetDatadir()
        : BitcoinCore().datadir();

    if (BitcoinCore().confFile() == 'bitcoin.conf') {
      return (hasPrivateConf: true, path: path.join(datadir, 'bitcoin.conf'));
    }

    // Fall back to our generated config
    final bitwindowConfPath = path.join(datadir, 'bitwindow-bitcoin.conf');
    return (hasPrivateConf: false, path: bitwindowConfPath);
  }

  /// Get the standard Bitcoin Core datadir for real mainnet
  String _getMainnetDatadir() {
    final appDir = BitcoinCore().appdir();
    return path.join(appDir, 'Bitcoin');
  }

  void _detectNetworkFromConfig() {
    if (_currentConfig == null) return;

    // Check for chain= setting first (preferred)
    final chainSetting = _currentConfig!.getSetting('chain');
    if (chainSetting != null) {
      switch (chainSetting.toLowerCase()) {
        case 'main':
        case 'mainnet':
          // Distinguish between real mainnet and forknet by checking for drivechain settings
          // Forknet configs have drivechain=1 in the main section
          final drivechainSetting = _currentConfig!.getEffectiveSetting('drivechain', 'main');
          if (drivechainSetting == '1') {
            _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_FORKNET;
          } else {
            _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_MAINNET;
          }
          return;
        case 'test':
        case 'testnet':
          _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_TESTNET;
          return;
        case 'signet':
          _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
          return;
        case 'regtest':
          _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
          return;
      }
    }

    // Check for legacy boolean flags
    if (_currentConfig!.getSetting('testnet') == '1') {
      _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_TESTNET;
      return;
    }
    if (_currentConfig!.getSetting('signet') == '1') {
      _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
      return;
    }
    if (_currentConfig!.getSetting('regtest') == '1') {
      _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      return;
    }

    // Default to signet if no network specified
    _detectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  }

  void _detectDataDirFromConfig() {
    if (_currentConfig == null) return;
    final section = _detectedNetwork.toCoreNetwork();
    // Read datadir from network-specific section first, fallback to global
    _detectedDataDir = _currentConfig!.getEffectiveSetting('datadir', section);
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

          // Save [main] section to network-specific file (bitwindow-bitcoin.conf is source of truth)
          await _syncMainSectionFile();

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
    final currentNetwork = _detectedNetwork.toCoreNetwork();

    // Real mainnet gets minimal standard Bitcoin Core config
    if (_detectedNetwork == BitcoinNetwork.BITCOIN_NETWORK_MAINNET) {
      final mainnetDatadir = _getMainnetDatadir();
      return '''# Generated code. Any changes to this file *will* get overwritten.
# source: bitwindow bitcoin config settings

# Standard Bitcoin Core mainnet configuration
datadir=$mainnetDatadir
rpcuser=user
rpcpassword=password
server=1
listen=1
txindex=1
chain=main
''';
    }

    // Forknet and other networks get full drivechain config
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
chain=$currentNetwork # current network

# [Sections]
# Most options automatically apply to mainnet, testnet,
# and regtest.

# If you want to confine an option to just one network,
# you should add it in the relevant section.

# EXCEPTIONS: The options addnode, connect, port, bind,
# rpcport, rpcbind and wallet
# only apply to mainnet unless they appear in the
# appropriate section below.

# Signet-specific settings
[signet]
addnode=172.105.148.135:38333
signetblocktime=60
signetchallenge=00141551188e5153533b4fdd555449e640d9cc129456
acceptnonstdtxn=1

# Forknet-specific settings (drivechain testnet on mainnet params)
[main]
port=8300
rpcport=18301
rpcbind=0.0.0.0
rpcallowip=0.0.0.0/0
zmqpubhashblock=tcp://0.0.0.0:29001
zmqpubhashtx=tcp://0.0.0.0:29002
zmqpubrawblock=tcp://0.0.0.0:29003
zmqpubrawtx=tcp://0.0.0.0:29004
assumevalid=0000000000000000000000000000000000000000000000000000000000000000
minimumchainwork=0x00
maxconnections=500
loglevel=trace
logips=1
logtimestamps=1
printtoconsole=1
debug=0
onion=0
listenonion=0
drivechain=1

# Testnet-specific settings
[test]

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

  /// Migrate legacy forknet section by removing it from the config
  Future<void> _migrateLegacyForknetSection(String content) async {
    if (!content.contains('[forknet]')) return;

    log.i('Removing legacy [forknet] section from config...');

    try {
      final confInfo = _getConfigFileInfo();
      final newContent = _removeForknetSection(content);
      await File(confInfo.path).writeAsString(newContent);
      log.i('Removed [forknet] section from config file');
    } catch (e) {
      log.e('Failed to rewrite config without [forknet]: $e');
    }
  }

  /// Remove forknet section from config content
  String _removeForknetSection(String content) {
    final lines = content.split('\n');
    final result = <String>[];
    bool inForknetSection = false;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        final section = trimmed.substring(1, trimmed.length - 1);
        inForknetSection = section == 'forknet';
        if (inForknetSection) {
          // Skip the [forknet] header and any comment before it
          if (result.isNotEmpty && result.last.trim().startsWith('#') && result.last.contains('forknet')) {
            result.removeLast();
          }
          continue;
        }
      }

      if (!inForknetSection) {
        result.add(line);
      }
    }

    return result.join('\n');
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
    String host = 'localhost';
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

  /// Get default [main] section settings for a network
  Map<String, String> _getDefaultMainSection(BitcoinNetwork network) {
    if (network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
      return {
        'port': '8300',
        'rpcport': '18301',
        'rpcbind': '0.0.0.0',
        'rpcallowip': '0.0.0.0/0',
        'zmqpubhashblock': 'tcp://0.0.0.0:29001',
        'zmqpubhashtx': 'tcp://0.0.0.0:29002',
        'zmqpubrawblock': 'tcp://0.0.0.0:29003',
        'zmqpubrawtx': 'tcp://0.0.0.0:29004',
        'assumevalid': '0000000000000000000000000000000000000000000000000000000000000000',
        'minimumchainwork': '0x00',
        'listenonion': '0',
        'drivechain': '1',
      };
    } else if (network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET) {
      // Real mainnet - minimal settings
      return {};
    }
    return {};
  }

  /// Sync [main] section to the network-specific file for current network
  Future<void> _syncMainSectionFile() async {
    if (_hasPrivateBitcoinConf) return;
    if (!_isMainnetOrForknet(_detectedNetwork)) return;
    await _saveMainSectionForNetwork(_detectedNetwork);
  }

  /// Get the path for the saved [main] section file for mainnet/forknet
  String _getMainSectionPath(BitcoinNetwork network) {
    final datadir = BitcoinCore().datadir();
    final networkName = network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ? 'forknet' : 'mainnet';
    return path.join(datadir, 'bitwindow-$networkName.conf');
  }

  /// Save current [main] section to file for the specified network (mainnet or forknet)
  Future<void> _saveMainSectionForNetwork(BitcoinNetwork network) async {
    if (_currentConfig == null) return;
    if (!_isMainnetOrForknet(network)) return;

    try {
      final confPath = _getMainSectionPath(network);
      final mainSettings = _currentConfig!.networkSettings['main'] ?? {};

      // Write as key=value pairs
      final buffer = StringBuffer();
      buffer.writeln('# Saved [main] section for $network');
      for (final entry in mainSettings.entries) {
        buffer.writeln('${entry.key}=${entry.value}');
      }

      await File(confPath).writeAsString(buffer.toString());
      log.i('Saved [main] section for $network to $confPath');
    } catch (e) {
      log.e('Failed to save [main] section for $network: $e');
    }
  }

  /// Load [main] section from file for the specified network (mainnet or forknet)
  Future<void> _loadMainSectionForNetwork(BitcoinNetwork network) async {
    if (_currentConfig == null) return;
    if (!_isMainnetOrForknet(network)) return;

    try {
      final confPath = _getMainSectionPath(network);
      final file = File(confPath);

      if (!await file.exists()) {
        log.i('No saved [main] section for $network, using defaults');
        // Apply default settings for this network (file watcher will save it)
        _currentConfig!.networkSettings['main'] = _getDefaultMainSection(network);
        return;
      }

      final content = await file.readAsString();
      final settings = <String, String>{};

      // Parse key=value pairs from saved file
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

        final equals = trimmed.indexOf('=');
        if (equals > 0) {
          final key = trimmed.substring(0, equals).trim();
          final value = trimmed.substring(equals + 1).trim();
          settings[key] = value;
        }
      }

      _currentConfig!.networkSettings['main'] = settings;
      log.i('Loaded [main] section for $network from $confPath');
    } catch (e) {
      log.e('Failed to load [main] section for $network: $e');
    }
  }

  /// Check if a network has a datadir configured (checks saved file for mainnet/forknet, config for others)
  String? getDataDirForNetwork(BitcoinNetwork network) {
    if (_currentConfig == null) return null;

    // For mainnet/forknet, check their saved config files since they share [main] section
    if (_isMainnetOrForknet(network)) {
      try {
        final confPath = _getMainSectionPath(network);
        final file = File(confPath);
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          for (final line in content.split('\n')) {
            final trimmed = line.trim();
            if (trimmed.startsWith('datadir=')) {
              return trimmed.substring('datadir='.length).trim();
            }
          }
        }
      } catch (e) {
        log.e('Failed to read datadir for $network: $e');
      }
      // Fall back to current [main] section if no saved file
      return _currentConfig!.networkSettings['main']?['datadir'];
    }

    // For other networks, read from their config section
    final section = network.toCoreNetwork();
    return _currentConfig!.getEffectiveSetting('datadir', section);
  }
}
