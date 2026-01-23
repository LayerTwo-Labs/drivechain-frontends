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
  StreamSubscription<FileSystemEvent>? _bitWindowWatcher;
  StreamSubscription<FileSystemEvent>? _drivechainWatcher;
  StreamSubscription<FileSystemEvent>? _bitcoinWatcher;
  Timer? _fileWatchDebouncer;

  // Config file state
  bool hasPrivateBitcoinConf = false;
  String? configPath;
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  /// Absolute path from bitcoin.conf's `datadir` setting (if configured)
  String? detectedDataDir;
  BitcoinConfig? currentConfig;

  /// Returns true if the current network supports sidechains (drivechain)
  bool get networkSupportsSidechains {
    return network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_SIGNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
  }

  /// Router for navigation (required for network swap dialogs)
  late final RootStackRouter router;

  /// Get the actual RPC port being used (respects user's rpcport setting from config + network section)
  int get rpcPort {
    if (currentConfig != null) {
      // Get effective setting (network section overrides global)
      // Use toCoreNetworkForBitcoinSettings() for Bitcoin Core settings like rpcport
      final rpcPortSetting = currentConfig!.getEffectiveSetting(
        'rpcport',
        network.toCoreNetworkForBitcoinSettings(),
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
    _bitWindowWatcher?.cancel();
    _drivechainWatcher?.cancel();
    _bitcoinWatcher?.cancel();
    _fileWatchDebouncer?.cancel();
    super.dispose();
  }

  Future<void> loadConfig({bool isFirst = false}) async {
    final oldNetwork = network;

    try {
      _parseAndApplyConfig(await _loadOrCreateConfigContent());

      if (await _tryLoadPrivateConfig()) {
        return; // Private config loaded, we're done, just use that
      }

      await _handleNetworkChangeIfNeeded(oldNetwork, isFirst);

      await _copyConfigDownstream();

      await _promptForDatadirIfNeeded();
    } catch (e) {
      log.e('Failed to load config: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Load config content from BitWindow config file, or create default if missing
  Future<String> _loadOrCreateConfigContent() async {
    final bitwindowFile = File(_getBitWindowConfigPath());

    if (await bitwindowFile.exists()) {
      return await bitwindowFile.readAsString();
    }

    // Create default config
    final content = _defaultConf();
    try {
      await bitwindowFile.parent.create(recursive: true);
      await bitwindowFile.writeAsString(content);
      log.i('Created default config file: ${bitwindowFile.path}');
    } catch (e) {
      log.e('Failed to write default config file: $e');
    }
    return content;
  }

  /// Parse config content and update state (network, datadir)
  void _parseAndApplyConfig(String content) {
    currentConfig = BitcoinConfig.parse(content);
    _loadStateFromConfig();
  }

  /// Check for user's private bitcoin.conf and load if exists
  /// Returns true if private config was loaded
  Future<bool> _tryLoadPrivateConfig() async {
    final confInfo = _getConfigFileInfo();
    hasPrivateBitcoinConf = confInfo.hasPrivateConf;
    configPath = confInfo.path;

    if (!hasPrivateBitcoinConf) return false;

    final privateFile = File(confInfo.path);
    if (!await privateFile.exists()) return false;

    final content = await privateFile.readAsString();
    _parseAndApplyConfig(content);
    return true;
  }

  /// Handle network change: load saved settings, write config, restart services
  Future<void> _handleNetworkChangeIfNeeded(BitcoinNetwork oldNetwork, bool isFirst) async {
    final networkChanged = !isFirst && oldNetwork != network;
    if (!networkChanged) return;

    // Load saved [main] section for the new network
    await _loadMainSectionForNetwork(network);
    _loadStateFromConfig();
    await _writeConfigFile();

    // Restart all services for the new network
    unawaited(_restartServicesForNetworkChange());
  }

  /// Prompt user to configure datadir if on mainnet/forknet and not set
  Future<void> _promptForDatadirIfNeeded() async {
    final needsDatadir = _isMainnetOrForknet(network) && (detectedDataDir == null || detectedDataDir!.isEmpty);
    if (needsDatadir) {
      await router.push(DataDirSetupRoute());
    }
  }

  /// Writes the new network to the config file
  Future<void> updateNetwork(BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) {
      log.w('Cannot update network - controlled by your bitcoin.conf');
      return;
    }

    if (currentConfig == null) return;

    final chainValue = switch (newNetwork) {
      BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 'main',
      BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 'main',
      BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 'test',
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
      _ => 'signet',
    };
    currentConfig!.setSetting('chain', chainValue);

    if (newNetwork == BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
      currentConfig!.setSetting('drivechain', '1', section: 'main');
    } else if (newNetwork == BitcoinNetwork.BITCOIN_NETWORK_MAINNET) {
      currentConfig!.removeSetting('drivechain', section: 'main');
    }

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

  Future<void> swapNetwork(BuildContext context, BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) {
      log.w('Cannot swap network - controlled by user bitcoin.conf');
      return;
    }

    if (network == newNetwork) return;

    await updateNetwork(newNetwork);
  }

  /// Restart services when network changes (called from loadConfig)
  Future<void> _restartServicesForNetworkChange() async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    // Stop all services
    log.i('Network changed, stopping services');
    await binaryProvider.stop(BitcoinCore());
    await binaryProvider.stop(Enforcer());
    await binaryProvider.stop(BitWindow());

    // Clear sync state from old network
    try {
      final syncProvider = GetIt.I.get<SyncProvider>();
      syncProvider.clearState();
    } catch (e) {
      log.w('Could not clear sync provider state: $e');
    }

    // Update RPC config BEFORE starting so it connects to the right port
    _updateMainchainRPCConfig(_createConnectionSettings());

    // Restart all services (datadir guard will block if needed)
    log.i('Starting services for network: $network');
    final bitwindowBinary = binaryProvider.binaries.firstWhere((b) => b is BitWindow);
    await binaryProvider.startWithEnforcer(
      bitwindowBinary,
      bootExtraBinaryImmediately: true,
      bootCoreWithoutAwait: true,
      bootEnforcerWithoutAwait: true,
    );

    log.i('Services restarted for network: $network');
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
    final section = targetNetwork.toCoreNetwork();

    if (dataDir == null || dataDir.isEmpty) {
      currentConfig!.removeSetting('datadir', section: section);
    } else {
      // Strip any erroneous backslash escaping (e.g., "\ " -> " ")
      // Bitcoin Core config files don't use shell-style escaping
      final cleanDataDir = dataDir.replaceAll(r'\ ', ' ');
      currentConfig!.setSetting('datadir', cleanDataDir, section: section);
    }

    await _saveConfig();
  }

  /// Write config to file without triggering loadConfig
  Future<void> _writeConfigFile() async {
    if (currentConfig == null) return;
    if (hasPrivateBitcoinConf) return;

    try {
      final confFile = _getConfigFileInfo();
      final file = File(confFile.path);
      await file.parent.create(recursive: true);
      await file.writeAsString(currentConfig!.serialize());
      log.d('Wrote config file: ${confFile.path}');
    } catch (e) {
      log.e('Failed to write config file: $e');
    }
  }

  Future<void> _saveConfig() async {
    if (currentConfig == null) return;
    if (hasPrivateBitcoinConf) {
      log.w('Cannot save - user bitcoin.conf takes precedence');
      return;
    }

    try {
      await _writeConfigFile();

      // Only save main section backup if NOT a network switch
      final newNetwork = _getNetwork();
      if (network == newNetwork) {
        await _saveMainSectionForNetwork(network);
      }

      await loadConfig();
    } catch (e) {
      log.e('Failed to save config: $e');
    } finally {
      notifyListeners();
    }
  }

  ({bool hasPrivateConf, String path}) _getConfigFileInfo() {
    // Use network-specific datadir:
    // - MAINNET: ~/Library/Application Support/Bitcoin (standard Bitcoin Core)
    // - FORKNET/SIGNET/TESTNET/REGTEST: ~/Library/Application Support/Drivechain
    final datadir = network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET ? _getMainnetDatadir() : BitcoinCore().datadir();

    // Check if user has a private bitcoin.conf for the current network (Bitcoin/ or Drivechain/)
    final bitcoinConf = File(path.join(datadir, 'bitcoin.conf'));
    if (bitcoinConf.existsSync()) {
      return (hasPrivateConf: true, path: bitcoinConf.path);
    }

    // Use BitWindow directory as the source of truth for generated config
    return (hasPrivateConf: false, path: _getBitWindowConfigPath());
  }

  /// Get the standard Bitcoin Core datadir for real mainnet
  String _getMainnetDatadir() {
    final appDir = BitcoinCore().appdir();
    return path.join(appDir, 'Bitcoin');
  }

  /// Get the path to the config file in BitWindow directory (source of truth)
  String _getBitWindowConfigPath() {
    return path.join(BitWindow().datadir(), 'bitwindow-bitcoin.conf');
  }

  /// Get the path where config should be copied for Bitcoin Core to find
  String _getDownstreamConfigPath() {
    final datadir = network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET ? _getMainnetDatadir() : BitcoinCore().datadir();
    return path.join(datadir, 'bitwindow-bitcoin.conf');
  }

  /// Copy config from BitWindow directory to downstream location (Drivechain or Bitcoin dir)
  Future<void> _copyConfigDownstream() async {
    try {
      final sourcePath = _getBitWindowConfigPath();
      final destPath = _getDownstreamConfigPath();

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        log.w('Cannot copy downstream - source file does not exist: $sourcePath');
        return;
      }

      final destFile = File(destPath);
      await destFile.parent.create(recursive: true);
      await sourceFile.copy(destPath);

      log.d('Copied config downstream: $sourcePath -> $destPath');
    } catch (e) {
      log.e('Failed to copy config downstream: $e');
    }
  }

  /// Sync config from upstream location (Drivechain or Bitcoin dir) to BitWindow directory
  Future<void> _syncConfigUpstream(String upstreamPath) async {
    if (hasPrivateBitcoinConf) return;

    try {
      final destPath = _getBitWindowConfigPath();

      final sourceFile = File(upstreamPath);
      if (!await sourceFile.exists()) {
        log.w('Cannot sync upstream - source file does not exist: $upstreamPath');
        return;
      }

      final destFile = File(destPath);
      await destFile.parent.create(recursive: true);
      await sourceFile.copy(destPath);

      log.d('Synced config upstream: $upstreamPath -> $destPath');
    } catch (e) {
      log.e('Failed to sync config upstream: $e');
    }
  }

  /// Load network and datadir state from currentConfig
  void _loadStateFromConfig() {
    if (currentConfig == null) return;

    network = _getNetwork();
    detectedDataDir = currentConfig!.getEffectiveSetting('datadir', network.toCoreNetwork());

    // Ensure datadir exists - Bitcoin Core fails with a cryptic assertion error (exit code -6) if it doesn't
    if (detectedDataDir != null && detectedDataDir!.isNotEmpty) {
      Directory(detectedDataDir!).createSync(recursive: true);
    }
  }

  void _setupFileWatching() {
    _setupBitWindowWatcher();
    _setupUpstreamWatcher();
  }

  /// Primary watcher: watches BitWindow directory (source of truth)
  void _setupBitWindowWatcher() {
    _bitWindowWatcher?.cancel();

    try {
      final bitWindowDir = Directory(BitWindow().datadir());
      if (!bitWindowDir.existsSync()) {
        bitWindowDir.createSync(recursive: true);
      }

      _bitWindowWatcher = bitWindowDir
          .watch(events: FileSystemEvent.modify | FileSystemEvent.create | FileSystemEvent.delete)
          .where((event) => event.path.endsWith('bitwindow-bitcoin.conf'))
          .listen(_handleBitWindowConfigChange);

      log.d('BitWindow config watcher enabled for ${bitWindowDir.path}');
    } catch (e) {
      log.e('Failed to setup BitWindow watcher: $e');
    }
  }

  /// Upstream watcher: watches both Drivechain and Bitcoin directories
  void _setupUpstreamWatcher() {
    _drivechainWatcher?.cancel();
    _bitcoinWatcher?.cancel();

    try {
      // Watch Drivechain directory (for signet/forknet/etc)
      final drivechainDir = Directory(BitcoinCore().datadir());
      if (drivechainDir.existsSync()) {
        _drivechainWatcher = drivechainDir
            .watch(events: FileSystemEvent.modify | FileSystemEvent.create | FileSystemEvent.delete)
            .where((event) => event.path.endsWith('bitwindow-bitcoin.conf'))
            .listen(_handleUpstreamConfigChange);
        log.d('Drivechain config watcher enabled for ${drivechainDir.path}');
      }

      // Watch Bitcoin directory (for mainnet)
      final bitcoinDir = Directory(_getMainnetDatadir());
      if (bitcoinDir.existsSync()) {
        _bitcoinWatcher = bitcoinDir
            .watch(events: FileSystemEvent.modify | FileSystemEvent.create | FileSystemEvent.delete)
            .where((event) => event.path.endsWith('bitwindow-bitcoin.conf'))
            .listen(_handleUpstreamConfigChange);
        log.d('Bitcoin config watcher enabled for ${bitcoinDir.path}');
      }
    } catch (e) {
      log.e('Failed to setup upstream watchers: $e');
    }
  }

  /// Handle changes to the BitWindow config file (primary source of truth)
  void _handleBitWindowConfigChange(FileSystemEvent event) {
    log.d('BitWindow config changed: ${event.path}');

    _fileWatchDebouncer?.cancel();
    _fileWatchDebouncer = Timer(const Duration(milliseconds: 50), () async {
      // Loop prevention: compare new config to current config
      try {
        final file = File(event.path);
        if (!await file.exists()) return;

        final content = await file.readAsString();
        final newConfig = BitcoinConfig.parse(content);

        if (currentConfig != null && newConfig == currentConfig) {
          log.d('Config unchanged, skipping reload');
          return;
        }

        await loadConfig();
        await _copyConfigDownstream();
      } catch (e) {
        log.e('Error handling BitWindow config change: $e');
      }
    });
  }

  /// Handle changes to upstream config files (Drivechain or Bitcoin dir)
  void _handleUpstreamConfigChange(FileSystemEvent event) {
    log.d('Upstream config changed: ${event.path}');

    _fileWatchDebouncer?.cancel();
    _fileWatchDebouncer = Timer(const Duration(milliseconds: 50), () async {
      // Sync upstream file to BitWindow dir - this will trigger the primary watcher
      await _syncConfigUpstream(event.path);
    });
  }

  /// Get the default configuration content
  String getDefaultConfig() {
    // network is always set by loadConfig() before this is called
    final effectiveNetwork = network;
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
      final confFile = _getConfigFileInfo();
      final file = File(confFile.path);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
      log.i('Saved config to ${confFile.path}');
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
      network: network,
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
  /// Stored in BitWindow directory alongside the main config
  String _getMainSectionPath(BitcoinNetwork network) {
    final datadir = BitWindow().datadir();
    final networkName = network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ? 'forknet' : 'mainnet';
    return path.join(datadir, 'bitwindow-$networkName.conf');
  }

  /// Save current main-section to file for the specified network (mainnet or forknet)
  Future<void> _saveMainSectionForNetwork(BitcoinNetwork network) async {
    if (currentConfig == null) return;
    if (!_isMainnetOrForknet(network)) return;

    try {
      final confPath = _getMainSectionPath(network);
      final file = File(confPath);
      await file.parent.create(recursive: true);

      final mainSettings = currentConfig!.networkSettings['main'] ?? {};

      // Write as key=value pairs
      final buffer = StringBuffer();
      buffer.writeln('# Saved [main] section for $network');
      for (final entry in mainSettings.entries) {
        buffer.writeln('${entry.key}=${entry.value}');
      }

      final contentToWrite = buffer.toString();
      await file.writeAsString(contentToWrite);

      // Verify the write
      final writtenContent = await file.readAsString();
      if (writtenContent != contentToWrite) {
        log.e('Main section verification failed for $confPath');
        return;
      }

      log.i('Saved and verified [main] section for $network to $confPath');
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
