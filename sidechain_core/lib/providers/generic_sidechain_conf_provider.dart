import 'dart:async';
import 'dart:io' show Directory, File, FileSystemEvent;

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sidechain_core/sidechain_core.dart';

/// Abstract base class for sidechain configuration providers.
/// Sidechains don't read from a conf file directly - they only accept CLI arguments.
/// We store settings in a file and convert them to CLI args at launch time.
abstract class GenericSidechainConfProvider extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();

  StreamSubscription<FileSystemEvent>? _fileWatcher;
  Timer? _fileWatchDebouncer;

  GenericAppConfig? currentConfig;
  String? configPath;

  /// The display name for this sidechain (e.g., "Thunder", "BitAssets", "BitNames")
  String get appName;

  /// The config filename (e.g., "thunder.conf", "bitassets.conf")
  String get configFileName;

  /// Get the data directory for this sidechain
  String getDataDir();

  /// Get network-specific port mappings
  Map<String, String> getNetworkPorts(String network);

  /// Get the default configuration content
  String getDefaultConfig();

  /// Apply network-specific settings to the config when network changes
  void applyNetworkSettings(String network) {
    final ports = getNetworkPorts(network);
    for (final entry in ports.entries) {
      currentConfig!.setSetting(entry.key, entry.value);
    }
  }

  /// Override this to filter out keys that shouldn't be passed as CLI args
  List<String> get skippedCliKeys => [];

  /// Initialize the provider (call from subclass create() method)
  Future<void> initialize() async {
    await loadConfig();
    _setupFileWatching();
    _listenToBitcoinConf();
    await syncNetworkFromBitcoinConf();
  }

  void _listenToBitcoinConf() {
    GetIt.I.get<BitcoinConfProvider>().addListener(_onBitcoinConfChanged);
  }

  void _onBitcoinConfChanged() {
    syncNetworkFromBitcoinConf();
  }

  Future<void> _saveConfig() async {
    if (currentConfig == null) {
      return;
    }
    try {
      final confPath = _getConfigPath();
      final file = File(confPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(currentConfig!.serialize());
      log.i('Saved $appName config to $confPath');
    } catch (e) {
      log.e('Failed to save $appName config: $e');
    }
  }

  /// The network the sidechain follows. It comes from the mainchain conf, never
  /// from the sidechain file, so the two can never disagree.
  ///
  /// Sidechains run on signet, regtest, forknet and eCash. Real mainnet has no
  /// drivechain yet, and forknet and eCash share the mainnet port group.
  String get network {
    final mainchain = GetIt.I.get<BitcoinConfProvider>().network;
    return switch (mainchain) {
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
      BitcoinNetwork.BITCOIN_NETWORK_FORKNET || BitcoinNetwork.BITCOIN_NETWORK_ECASH => 'mainnet',
      _ => 'signet',
    };
  }

  /// Point the generated endpoints at the network the mainchain runs. The file
  /// holds no network key, so a stale one from an older build goes away here.
  Future<void> syncNetworkFromBitcoinConf() async {
    if (currentConfig == null) {
      return;
    }

    var changed = false;
    if (currentConfig!.getSetting('network') != null) {
      currentConfig!.removeSetting('network');
      changed = true;
    }
    for (final entry in getNetworkPorts(network).entries) {
      final current = currentConfig!.getSetting(entry.key);
      if (current == entry.value || !_isGeneratedEndpoint(entry.key, current)) {
        continue;
      }
      currentConfig!.setSetting(entry.key, entry.value);
      changed = true;
    }
    if (!changed) {
      return;
    }

    notifyListeners();
    await _saveConfig();
  }

  /// Reports whether value is the value this key takes on one of the networks.
  /// Such a value came from an earlier sync, so a network change may replace
  /// it. Anything else came from the user, and the sync keeps it.
  bool _isGeneratedEndpoint(String key, String? value) {
    if (value == null || value.isEmpty) {
      return true;
    }
    for (final network in ['signet', 'regtest', 'mainnet']) {
      if (getNetworkPorts(network)[key] == value) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _fileWatcher?.cancel();
    _fileWatchDebouncer?.cancel();
    try {
      GetIt.I.get<BitcoinConfProvider>().removeListener(_onBitcoinConfChanged);
    } catch (_) {}
    super.dispose();
  }

  /// Get the path to the config file
  String _getConfigPath() {
    final datadir = getDataDir();
    return path.join(datadir, configFileName);
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
          log.i('Created default $appName config file: ${file.path}');
        } catch (e) {
          log.e('Failed to write default $appName config file: $e');
        }
      }

      currentConfig = GenericAppConfig.parse(content, appName: appName);
    } catch (e) {
      log.e('Failed to load $appName config: $e');
    } finally {
      notifyListeners();
    }
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
      final config = GenericAppConfig.parse(content, appName: appName);
      currentConfig = config;

      final confPath = _getConfigPath();
      final file = File(confPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);

      log.i('Saved $appName config to $confPath');
      notifyListeners();
    } catch (e) {
      log.e('Failed to write $appName config: $e');
      rethrow;
    }
  }

  /// Convert current config to CLI args
  List<String> getCliArgs() {
    final args = <String>[];

    if (currentConfig == null) {
      return args;
    }

    for (final entry in currentConfig!.settings.entries) {
      final key = entry.key;
      final value = entry.value;

      // Skip keys that shouldn't be passed as CLI args
      if (skippedCliKeys.contains(key)) {
        continue;
      }

      if (value == 'true') {
        args.add('--$key');
      } else if (value == 'false') {
        continue;
      } else if (value.isNotEmpty) {
        args.add('--$key=$value');
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
          .watch(
            events: FileSystemEvent.modify | FileSystemEvent.create | FileSystemEvent.delete,
          )
          .where((event) => event.path.endsWith(configFileName))
          .listen(_handleFileSystemEvent);

      log.d('$appName config file watching enabled for ${confDir.path}');
    } catch (e) {
      log.e('Failed to setup $appName config file watching: $e');
    }
  }

  void _handleFileSystemEvent(FileSystemEvent event) {
    log.d('$appName config file changed: ${event.path}');

    _fileWatchDebouncer?.cancel();
    _fileWatchDebouncer = Timer(const Duration(milliseconds: 500), () {
      _reloadConfigFromFileSystem();
    });
  }

  void _reloadConfigFromFileSystem() async {
    try {
      log.i('Reloading $appName config due to file system change');

      final confPath = _getConfigPath();
      final file = File(confPath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final newConfig = GenericAppConfig.parse(content, appName: appName);

        if (newConfig != currentConfig) {
          currentConfig = newConfig;
          notifyListeners();
        }
      }
    } catch (e) {
      log.e('Failed to reload $appName config from file system: $e');
    }
  }
}
