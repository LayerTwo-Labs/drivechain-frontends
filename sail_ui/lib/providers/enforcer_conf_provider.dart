import 'dart:async';
import 'dart:io' show Directory, File, FileSystemEvent, Platform;

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

/// Provider for Enforcer configuration settings.
/// Unlike Bitcoin Core, the Enforcer doesn't read from a conf file directly -
/// it only accepts CLI arguments. We store settings in a file and convert them
/// to CLI args at launch time.
class EnforcerConfProvider extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();

  StreamSubscription<FileSystemEvent>? _fileWatcher;
  Timer? _fileWatchDebouncer;

  EnforcerConfig? currentConfig;
  String? configPath;

  EnforcerConfProvider._create();

  static Future<EnforcerConfProvider> create() async {
    final instance = EnforcerConfProvider._create();
    await instance.loadConfig();
    instance._setupFileWatching();
    instance._listenToBitcoinConf();
    await instance.syncNodeRpcFromBitcoinConf();
    return instance;
  }

  void _listenToBitcoinConf() {
    GetIt.I.get<BitcoinConfProvider>().addListener(_onBitcoinConfChanged);
  }

  void _onBitcoinConfChanged() {
    // Sync node-rpc settings when Bitcoin config changes (e.g., network switch)
    // syncNodeRpcFromBitcoinConf() is async and handles saving internally
    syncNodeRpcFromBitcoinConf();
  }

  Future<void> _saveConfig() async {
    if (currentConfig == null) return;
    try {
      final confPath = _getConfigPath();
      final file = File(confPath);
      await file.writeAsString(currentConfig!.serialize());
      log.i('Saved enforcer config to $confPath');
    } catch (e) {
      log.e('Failed to save enforcer config: $e');
    }
  }

  /// Check if local node-rpc settings differ from BitcoinConfProvider
  bool get nodeRpcDiffers {
    if (currentConfig == null) return false;

    final expected = getExpectedNodeRpcSettings();
    final localUser = currentConfig!.getSetting('node-rpc-user') ?? '';
    final localPass = currentConfig!.getSetting('node-rpc-pass') ?? '';
    final localAddr = currentConfig!.getSetting('node-rpc-addr') ?? '';

    return localUser != expected['node-rpc-user'] ||
        localPass != expected['node-rpc-pass'] ||
        localAddr != expected['node-rpc-addr'];
  }

  /// Get expected node-rpc settings from BitcoinConfProvider
  Map<String, String> getExpectedNodeRpcSettings() {
    final host = Platform.isWindows ? 'localhost' : '0.0.0.0';
    final bitcoinConfProvider = GetIt.I.get<BitcoinConfProvider>();
    final port = bitcoinConfProvider.rpcPort;

    if (bitcoinConfProvider.currentConfig == null) {
      return {
        'node-rpc-user': 'user',
        'node-rpc-pass': 'password',
        'node-rpc-addr': '$host:$port',
      };
    }

    final config = bitcoinConfProvider.currentConfig!;
    final networkSection = (bitcoinConfProvider.network).toCoreNetwork();

    final username = config.getEffectiveSetting('rpcuser', networkSection) ?? 'user';
    final password = config.getEffectiveSetting('rpcpassword', networkSection) ?? 'password';

    return {
      'node-rpc-user': username,
      'node-rpc-pass': password,
      'node-rpc-addr': '$host:$port',
    };
  }

  /// Manually sync node-rpc settings from BitcoinConfProvider and save to file
  Future<void> syncNodeRpcFromBitcoinConf() async {
    if (currentConfig == null) return;

    final expected = getExpectedNodeRpcSettings();
    currentConfig!.setSetting('node-rpc-user', expected['node-rpc-user']!);
    currentConfig!.setSetting('node-rpc-pass', expected['node-rpc-pass']!);
    currentConfig!.setSetting('node-rpc-addr', expected['node-rpc-addr']!);

    // Sync esplora URL based on current network
    final bitcoinConfProvider = GetIt.I.get<BitcoinConfProvider>();
    final network = bitcoinConfProvider.network;
    final esploraUrl = getEsploraUrlForNetwork(network);
    if (esploraUrl != null) {
      currentConfig!.setSetting('wallet-esplora-url', esploraUrl);
    } else {
      currentConfig!.removeSetting('wallet-esplora-url');
    }

    // Sync datadir from BitcoinConfProvider
    final dataDir = bitcoinConfProvider.detectedDataDir;
    if (dataDir != null && dataDir.isNotEmpty) {
      currentConfig!.setSetting('datadir', dataDir);
    } else {
      currentConfig!.removeSetting('datadir');
    }

    notifyListeners();
    await _saveConfig();
  }

  @override
  void dispose() {
    _fileWatcher?.cancel();
    _fileWatchDebouncer?.cancel();
    GetIt.I.get<BitcoinConfProvider>().removeListener(_onBitcoinConfChanged);
    super.dispose();
  }

  /// Get the path to the enforcer config file
  String _getConfigPath() {
    return path.join(BitWindow().rootDir(), 'bitwindow-enforcer.conf');
  }

  /// Load config from file, or create default if not exists
  Future<void> loadConfig() async {
    try {
      configPath = _getConfigPath();
      final file = File(configPath!);

      String content = '';
      if (await file.exists()) {
        content = await file.readAsString();
      } else {
        content = getDefaultConfig();

        try {
          await file.parent.create(recursive: true);
          await file.writeAsString(content);
          log.i('Created default enforcer config file: ${file.path}');
        } catch (e) {
          log.e('Failed to write default enforcer config file: $e');
        }
      }

      currentConfig = EnforcerConfig.parse(content);
    } catch (e) {
      log.e('Failed to load enforcer config: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Get the default configuration content
  String getDefaultConfig() {
    final nodeRpc = getExpectedNodeRpcSettings();
    // Get esplora URL for current network
    final esploraUrl = getEsploraUrlForNetwork(GetIt.I.get<BitcoinConfProvider>().network);

    return '''# Enforcer Configuration - Generated by BitWindow
# These settings are converted to CLI arguments when the Enforcer starts.

# Enable wallet functionality (default: true)
enable-wallet=true

# Enable mempool support - required for getblocktemplate (default: true)
enable-mempool=true

# Node RPC settings (synced from Bitcoin Core config)
node-rpc-user=${nodeRpc['node-rpc-user']}
node-rpc-pass=${nodeRpc['node-rpc-pass']}
node-rpc-addr=${nodeRpc['node-rpc-addr']}

# Network-specific esplora URL
${esploraUrl != null ? 'wallet-esplora-url=$esploraUrl' : '# wallet-esplora-url='}
''';
  }

  /// Get the current configuration content as string
  String getCurrentConfigContent() {
    if (currentConfig == null) {
      return getDefaultConfig();
    }
    return currentConfig!.serialize();
  }

  /// Write configuration content to the file
  Future<void> writeConfig(String content) async {
    try {
      final config = EnforcerConfig.parse(content);
      currentConfig = config;

      final confPath = _getConfigPath();
      final file = File(confPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);

      log.i('Saved enforcer config to $confPath');
      notifyListeners();
    } catch (e) {
      log.e('Failed to write enforcer config: $e');
      rethrow;
    }
  }

  /// Get network-specific esplora URL
  String? getEsploraUrlForNetwork(BitcoinNetwork network) {
    switch (network) {
      case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
        return 'http://localhost:3003';

      case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
        return null;

      case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
        return 'https://explorer.signet.drivechain.info/api';

      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
        return 'https://mempool.space/api';

      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        return 'https://explorer.forknet.drivechain.info/api';

      default:
        return null;
    }
  }

  /// Convert current config to CLI args for the enforcer
  List<String> getCliArgs(BitcoinNetwork network) {
    final args = <String>[];

    if (currentConfig == null) return args;

    for (final entry in currentConfig!.settings.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == 'true') {
        args.add('--$key');
      } else if (value == 'false') {
        continue;
      } else if (value.isNotEmpty) {
        args.add('--$key=$value');
      }
    }

    if (!currentConfig!.hasSetting('wallet-esplora-url')) {
      final esploraUrl = getEsploraUrlForNetwork(network);
      if (esploraUrl != null && esploraUrl.isNotEmpty) {
        args.add('--wallet-esplora-url=$esploraUrl');
      }
    }

    return args;
  }

  void _setupFileWatching() {
    _fileWatcher?.cancel();

    try {
      final confPath = _getConfigPath();
      final confDir = Directory(path.dirname(confPath));

      if (!confDir.existsSync()) {
        confDir.createSync(recursive: true);
      }

      _fileWatcher = confDir
          .watch(events: FileSystemEvent.modify | FileSystemEvent.create | FileSystemEvent.delete)
          .where((event) => event.path.endsWith('bitwindow-enforcer.conf'))
          .listen(_handleFileSystemEvent);

      log.d('Enforcer config file watching enabled for ${confDir.path}');
    } catch (e) {
      log.e('Failed to setup enforcer config file watching: $e');
    }
  }

  void _handleFileSystemEvent(FileSystemEvent event) {
    log.d('Enforcer config file changed: ${event.path}');

    // Debounce file changes to avoid rapid reloads
    _fileWatchDebouncer?.cancel();
    _fileWatchDebouncer = Timer(const Duration(milliseconds: 500), () {
      _reloadConfigFromFileSystem();
    });
  }

  void _reloadConfigFromFileSystem() async {
    try {
      log.i('Reloading enforcer config due to file system change');

      final confPath = _getConfigPath();
      final file = File(confPath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final newConfig = EnforcerConfig.parse(content);

        if (newConfig != currentConfig) {
          currentConfig = newConfig;
          notifyListeners();
        }
      }
    } catch (e) {
      log.e('Failed to reload enforcer config from file system: $e');
    }
  }
}
