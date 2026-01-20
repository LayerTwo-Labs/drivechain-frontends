import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/pages/router.gr.dart';
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
  bool hasPrivateBitcoinConf = false;
  String? configPath;
  BitcoinNetwork? network;
  String? detectedDataDir;
  BitcoinConfig? currentConfig;

  /// Router for navigation (required for network swap dialogs)
  late final RootStackRouter router;

  /// Get the actual RPC port being used (respects user's rpcport setting from config + network section)
  int get rpcPort {
    if (currentConfig != null && network != null) {
      // Get effective setting (network section overrides global)
      // Use toCoreNetworkForBitcoinSettings() for Bitcoin Core settings like rpcport
      final rpcPortSetting = currentConfig!.getEffectiveSetting(
        'rpcport',
        network!.toCoreNetworkForBitcoinSettings(),
      );
      if (rpcPortSetting != null) {
        final customPort = int.tryParse(rpcPortSetting);
        if (customPort != null) {
          return customPort;
        }
      }
    }

    // Fall back to network defaults if no custom port set
    return switch (network) {
      BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 8332, // real Bitcoin mainnet
      BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 18301, // forknet
      BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 18332,
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 38332,
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 18443,
      _ => 38332, // fallback to signet
    };
  }

  // Private constructor
  BitcoinConfProvider._create(this.router);

  // Async factory
  static Future<BitcoinConfProvider> create(RootStackRouter router) async {
    final instance = BitcoinConfProvider._create(router);
    await instance.loadConfig(isFirst: true);
    instance._setupFileWatching();
    instance._updateMainchainRPCConfig(instance._createConnectionSettings());
    return instance;
  }

  @override
  void dispose() {
    _fileWatcher?.cancel();
    _fileWatchDebouncer?.cancel();
    super.dispose();
  }

  Future<void> loadConfig({bool isFirst = false}) async {
    try {
      // On first load, set a default network so config file path detection and
      // default config generation work correctly
      if (isFirst && network == null) {
        network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
      }

      // Determine which config file to use
      final confInfo = _getConfigFileInfo();
      hasPrivateBitcoinConf = confInfo.hasPrivateConf;
      configPath = confInfo.path;

      // Load the active config file
      final file = File(confInfo.path);
      String content = '';
      if (await file.exists()) {
        content = await file.readAsString();
      } else {
        // Use the default config if no file exists
        content = _defaultConf();

        // Write default config to disk if we're using bitwindow-bitcoin.conf (not user bitcoin.conf)
        if (!hasPrivateBitcoinConf) {
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
      currentConfig = BitcoinConfig.parse(content);

      // Detect if network changed (user might have edited file manually)
      // On first load, oldNetwork is just our default, not a real previous state
      final oldNetwork = network;
      final newNetwork = _getNetwork();
      final networkChanged = !isFirst && oldNetwork != null && oldNetwork != newNetwork;

      // If network changed (not first load), do a proper swap (save old [main], load new [main])
      if (networkChanged) {
        if (_isMainnetOrForknet(oldNetwork)) {
          await _saveMainSectionForNetwork(oldNetwork);
        }
        if (_isMainnetOrForknet(newNetwork)) {
          await _loadMainSectionForNetwork(newNetwork);
        }
      } else if (_isMainnetOrForknet(newNetwork)) {
        // Same network or first load, just load the [main] section
        await _loadMainSectionForNetwork(newNetwork);
      }

      // Derive state from config
      _loadStateFromConfig();

      notifyListeners();
    } catch (e) {
      log.e('Failed to load config: $e');
    }
  }

  /// Update network setting - only allowed when using bitwindow-bitcoin.conf
  /// Just writes the new network to file - loadConfig() handles the rest via file watcher
  Future<void> updateNetwork(BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) {
      log.w('Cannot update network - controlled by user bitcoin.conf');
      return;
    }

    if (currentConfig == null) return;

    // Just update the chain setting and drivechain flag
    if (_isMainnetOrForknet(newNetwork)) {
      currentConfig!.setSetting('chain', 'main');
      currentConfig!.networkSettings['main'] ??= {};
      if (newNetwork == BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
        currentConfig!.networkSettings['main']!['drivechain'] = '1';
      } else {
        currentConfig!.networkSettings['main']!.remove('drivechain');
      }
    } else {
      final chainValue = switch (newNetwork) {
        BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 'test',
        BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
        BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
        _ => 'signet',
      };
      currentConfig!.setSetting('chain', chainValue);
    }

    // Write to file - file watcher will call loadConfig() which handles the swap
    await _saveConfig();
  }

  /// Check if network is mainnet or forknet (both use main section)
  bool _isMainnetOrForknet(BitcoinNetwork network) {
    return network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET || network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET;
  }

  /// Get network from config
  BitcoinNetwork _getNetwork() {
    if (currentConfig == null) return BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

    final chainSetting = currentConfig!.getSetting('chain');
    if (chainSetting != null) {
      switch (chainSetting.toLowerCase()) {
        case 'main':
        case 'mainnet':
          final drivechainSetting = currentConfig!.getEffectiveSetting('drivechain', 'main');
          return drivechainSetting == '1'
              ? BitcoinNetwork.BITCOIN_NETWORK_FORKNET
              : BitcoinNetwork.BITCOIN_NETWORK_MAINNET;
        case 'test':
        case 'testnet':
          return BitcoinNetwork.BITCOIN_NETWORK_TESTNET;
        case 'signet':
          return BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
        case 'regtest':
          return BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
        default:
          return BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
      }
    } else if (currentConfig!.getSetting('testnet') == '1') {
      return BitcoinNetwork.BITCOIN_NETWORK_TESTNET;
    } else if (currentConfig!.getSetting('signet') == '1') {
      return BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    } else if (currentConfig!.getSetting('regtest') == '1') {
      return BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
    }
    return BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  }

  /// Swap to a new network with full UI feedback
  Future<void> swapNetwork(BuildContext context, BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) {
      log.w('Cannot swap network - controlled by user bitcoin.conf');
      return;
    }

    final oldNetwork = network;
    if (oldNetwork == newNetwork) return;

    // Save old [main] section if leaving mainnet/forknet
    if (oldNetwork != null && _isMainnetOrForknet(oldNetwork)) {
      await _saveMainSectionForNetwork(oldNetwork);
    }

    // Update the config file with new network
    await updateNetwork(newNetwork);

    // Load new [main] section if entering mainnet/forknet
    if (_isMainnetOrForknet(newNetwork)) {
      await _loadMainSectionForNetwork(newNetwork);
    }

    // Update state from config
    _loadStateFromConfig();
    notifyListeners();

    // For mainnet/forknet, ensure datadir is configured
    if (_isMainnetOrForknet(newNetwork) && (detectedDataDir == null || detectedDataDir!.isEmpty)) {
      await router.push(DataDirSetupRoute());
      // Re-check if datadir was actually set (user might have cancelled)
      if (detectedDataDir == null || detectedDataDir!.isEmpty) {
        log.w('Datadir setup cancelled, aborting network swap');
        // Revert to old network
        network = oldNetwork;
        if (oldNetwork != null) {
          await updateNetwork(oldNetwork);
        }
        notifyListeners();
        return;
      }
    }

    // Show progress dialog and restart services
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => NetworkSwapProgressDialog(
          fromNetwork: oldNetwork ?? BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
          toNetwork: newNetwork,
          swapFunction: (updateStatus) => _restartServicesWithStatus(newNetwork, updateStatus),
        ),
      );
    }
  }

  /// Restart services with status updates for progress dialog
  Future<void> _restartServicesWithStatus(BitcoinNetwork newNetwork, void Function(String) updateStatus) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    // Stop all services
    updateStatus('Stopping Bitcoin Core');
    await binaryProvider.stop(BitcoinCore());

    updateStatus('Stopping Enforcer');
    await binaryProvider.stop(Enforcer());

    updateStatus('Stopping BitWindow');
    await binaryProvider.stop(BitWindow());

    updateStatus('Waiting for processes to exit');

    // Clear sync state from old network
    try {
      final syncProvider = GetIt.I.get<SyncProvider>();
      syncProvider.clearState();
    } catch (e) {
      log.w('Could not clear sync provider state: $e');
    }

    // Restart all services
    updateStatus('Starting Core, Enforcer and BitWindow');
    final bitwindowBinary = binaryProvider.binaries.firstWhere((b) => b is BitWindow);
    await binaryProvider.startWithEnforcer(
      bitwindowBinary,
      bootExtraBinaryImmediately: true,
      bootCoreWithoutAwait: true,
      bootEnforcerWithoutAwait: true,
    );

    // await (somewhat) services to start
    await Future.delayed(const Duration(seconds: 2));

    _updateMainchainRPCConfig(_createConnectionSettings());

    updateStatus('Network swap complete');
    log.i('Services restarted for network: $newNetwork');
  }

  /// Update datadir for the specified network section (or current network if not specified)
  Future<void> updateDataDir(String? dataDir, {BitcoinNetwork? forNetwork}) async {
    if (hasPrivateBitcoinConf) {
      log.w('Cannot update datadir - controlled by your private bitcoin.conf');
      return;
    }

    if (currentConfig == null) return;

    // Use specified network or fall back to current detected network
    final targetNetwork = forNetwork ?? network;
    if (targetNetwork == null) return;
    final section = targetNetwork.toCoreNetwork();

    if (dataDir == null || dataDir.isEmpty) {
      currentConfig!.removeSetting('datadir', section: section);
      // Only update detectedDataDir if we're modifying the current network
      if (targetNetwork == network) {
        detectedDataDir = null;
      }
    } else {
      currentConfig!.setSetting('datadir', dataDir, section: section);
      // Only update detectedDataDir if we're modifying the current network
      if (targetNetwork == network) {
        detectedDataDir = dataDir;
      }
    }

    // Save the config file
    await _saveConfig();
  }

  // Private helper methods

  Future<void> _saveConfig() async {
    if (currentConfig == null) return;
    if (hasPrivateBitcoinConf) {
      log.w('Cannot save - user bitcoin.conf takes precedence');
      return;
    }

    try {
      final confFile = _getConfigFileInfo();
      final file = File(confFile.path);

      // Write new config
      await file.writeAsString(currentConfig!.serialize());
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
    final datadir = network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET ? _getMainnetDatadir() : BitcoinCore().datadir();

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

  /// Load network and datadir state from currentConfig
  void _loadStateFromConfig() {
    if (currentConfig == null) return;

    network = _getNetwork();
    detectedDataDir = currentConfig!.getEffectiveSetting('datadir', network!.toCoreNetwork());
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
      _fileWatchDebouncer = Timer(const Duration(milliseconds: 50), () {
        loadConfig();
      });
    }
  }

  /// Get the default configuration content
  String getDefaultConfig() {
    // network is always set by loadConfig() before this is called
    final effectiveNetwork = network ?? BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    final currentNetwork = effectiveNetwork.toCoreNetwork();

    // Real mainnet gets minimal standard Bitcoin Core config
    if (effectiveNetwork == BitcoinNetwork.BITCOIN_NETWORK_MAINNET) {
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

    // Build [main] section based on network
    final mainSection = effectiveNetwork == BitcoinNetwork.BITCOIN_NETWORK_FORKNET
        ? '''# Forknet-specific settings (drivechain testnet on mainnet params)
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
listenonion=0
drivechain=1
'''
        : '''# Fill mainnet-specific settings here
[main]
''';

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

$mainSection
# Testnet-specific settings
[test]

# Regtest-specific settings
[regtest]
''';
  }

  /// Get the current configuration content as string
  String getCurrentConfigContent() {
    if (currentConfig == null) {
      return getDefaultConfig();
    }
    return currentConfig!.serialize();
  }

  /// Write configuration content to the appropriate file
  Future<void> writeConfig(String content) async {
    if (hasPrivateBitcoinConf) {
      log.w('Cannot write config - user bitcoin.conf takes precedence');
      return;
    }

    try {
      final config = BitcoinConfig.parse(content);
      currentConfig = config;

      final confFile = _getConfigFileInfo();
      final file = File(confFile.path);
      await file.writeAsString(content);

      log.i('Saved config to $confFile');

      // Update detected network and datadir
      _loadStateFromConfig();

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
    String host = 'localhost';
    String username = 'user';
    String password = 'password';

    if (currentConfig != null) {
      host = currentConfig!.getSetting('rpcconnect') ?? currentConfig!.getSetting('rpchost') ?? host;
      username = currentConfig!.getSetting('rpcuser') ?? username;
      password = currentConfig!.getSetting('rpcpassword') ?? password;
    }

    return CoreConnectionSettings.fromParsedConfig(
      confPath: confInfo.path,
      host: host,
      port: rpcPort, // Use the getter which already handles network-specific logic
      username: username,
      password: password,
      network: network ?? BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
      configValues: currentConfig?.globalSettings ?? {},
      configFromFile: currentConfig?.globalSettings.keys.toSet() ?? {},
    );
  }

  /// Get default main-section settings for a network
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

  /// Get the path for the saved main-section file for mainnet/forknet
  String _getMainSectionPath(BitcoinNetwork network) {
    final datadir = BitcoinCore().datadir();
    final networkName = network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ? 'forknet' : 'mainnet';
    return path.join(datadir, 'bitwindow-$networkName.conf');
  }

  /// Save current main-section to file for the specified network (mainnet or forknet)
  Future<void> _saveMainSectionForNetwork(BitcoinNetwork network) async {
    if (currentConfig == null) return;
    if (!_isMainnetOrForknet(network)) return;

    try {
      final confPath = _getMainSectionPath(network);
      final mainSettings = currentConfig!.networkSettings['main'] ?? {};

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

  /// Load main-section from file for the specified network (mainnet or forknet)
  Future<void> _loadMainSectionForNetwork(BitcoinNetwork network) async {
    if (currentConfig == null) return;
    if (!_isMainnetOrForknet(network)) return;

    try {
      final confPath = _getMainSectionPath(network);
      final file = File(confPath);

      if (!await file.exists()) {
        log.i('No saved [main] section for $network, using defaults');
        // Apply default settings for this network (file watcher will save it)
        currentConfig!.networkSettings['main'] = _getDefaultMainSection(network);
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

      currentConfig!.networkSettings['main'] = settings;
      log.i('Loaded [main] section for $network from $confPath');
    } catch (e) {
      log.e('Failed to load [main] section for $network: $e');
    }
  }
}
