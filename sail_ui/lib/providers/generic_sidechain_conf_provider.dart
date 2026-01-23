import 'dart:async';
import 'dart:io' show Directory, File, FileSystemEvent;

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

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
    if (currentConfig == null) return;
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

  /// Sync network setting from BitcoinConfProvider
  Future<void> syncNetworkFromBitcoinConf() async {
    if (currentConfig == null) return;

    final bitcoinConfProvider = GetIt.I.get<BitcoinConfProvider>();
    final network = bitcoinConfProvider.network;

    // Sidechains only support signet and regtest
    final sidechainNetwork = switch (network) {
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
      _ => 'signet', // fallback for unsupported networks
    };

    final currentNetwork = currentConfig!.getSetting('network');
    if (currentNetwork != sidechainNetwork) {
      currentConfig!.setSetting('network', sidechainNetwork);
      applyNetworkSettings(sidechainNetwork);

      notifyListeners();
      await _saveConfig();
    }
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

    if (currentConfig == null) return args;

    for (final entry in currentConfig!.settings.entries) {
      final key = entry.key;
      final value = entry.value;

      // Skip keys that shouldn't be passed as CLI args
      if (skippedCliKeys.contains(key)) continue;

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
          .watch(events: FileSystemEvent.modify | FileSystemEvent.create | FileSystemEvent.delete)
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
