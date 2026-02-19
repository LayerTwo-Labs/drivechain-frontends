import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

class CoreConnectionSettings extends ChangeNotifier {
  // Core connection properties
  final String confPath;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool ssl = false;
  final BitcoinNetwork network;

  // Map to store arbitrary config values from config file
  final Map<String, String> configValues;

  // Set to track which config values came from config file
  final Set<String> configFromFile;

  CoreConnectionSettings(
    this.confPath,
    this.host,
    this.port,
    this.username,
    this.password,
    this.network, [
    Map<String, String>? additionalConfig,
  ]) : configValues = additionalConfig ?? {},
       configFromFile = {} {
    // Process additional config to track which values came from config file
    _processConfigFromFile();
  }

  /// Factory constructor for creating an empty/default config
  static CoreConnectionSettings empty([BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET]) {
    // Use correct default port based on network
    final defaultPort = switch (network) {
      BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 8332,
      BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 18301,
      BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 18332,
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 38332,
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 18443,
      _ => 38332, // fallback to signet
    };

    return CoreConnectionSettings(
      '',
      '127.0.0.1',
      defaultPort,
      'user',
      'password',
      network,
      {},
    );
  }

  /// Factory constructor for creating config from parsed file content
  factory CoreConnectionSettings.fromParsedConfig({
    required String confPath,
    required String host,
    required int port,
    required String username,
    required String password,
    required BitcoinNetwork network,
    required Map<String, String> configValues,
    required Set<String> configFromFile,
  }) {
    final settings = CoreConnectionSettings(
      confPath,
      host,
      port,
      username,
      password,
      network,
      configValues,
    );
    settings.configFromFile.addAll(configFromFile);
    return settings;
  }

  void _processConfigFromFile() {
    // All config values are assumed to come from file
    configValues.keys.forEach(configFromFile.add);
  }

  /// Check if a config parameter came from the config file
  bool isFromConfigFile(String key) => configFromFile.contains(key);

  /// Get additional config arguments for command line
  List<String> getCliConfigArgs() {
    final args = <String>[];
    configValues.forEach((key, value) {
      if (value == '1') {
        args.add('-$key');
      } else {
        args.add('-$key=$value');
      }
    });
    return args;
  }
}

/// Read mainchain configuration settings.
/// Optionally accepts a [provider] for use during initialization before GetIt registration.
CoreConnectionSettings readMainchainConf({BitcoinConfProvider? provider}) {
  final log = GetIt.I.get<Logger>();
  final confProvider = provider ?? GetIt.I.get<BitcoinConfProvider>();

  final network = confProvider.network;

  if (confProvider.currentConfig == null) {
    log.w('No config loaded, using defaults');
    return CoreConnectionSettings.empty(network);
  }

  final config = confProvider.currentConfig!;
  final networkSection = network.toCoreNetwork();

  // Read connection settings from config (null if not set)
  final configUsername = config.getEffectiveSetting('rpcuser', networkSection);
  final configPassword = config.getEffectiveSetting('rpcpassword', networkSection);
  final host =
      config.getEffectiveSetting('rpcconnect', networkSection) ??
      config.getEffectiveSetting('rpchost', networkSection) ??
      '127.0.0.1';
  final port = confProvider.rpcPort; // Uses the getter that already handles sections

  // Determine credentials: use config values, or fall back to cookie auth if both are empty
  String username;
  String password;

  final configHasCredentials = (configUsername?.isNotEmpty == true) && (configPassword?.isNotEmpty == true);

  if (configHasCredentials) {
    // Use credentials from config
    username = configUsername!;
    password = configPassword!;
  } else {
    // Try cookie auth - Bitcoin Core creates .cookie when no rpcuser/rpcpassword configured
    // Use provider's detectedDataDir if available, otherwise use rootDir to avoid GetIt during init
    final datadir = confProvider.detectedDataDir?.isNotEmpty == true
        ? confProvider.detectedDataDir!
        : BitcoinCore().rootDirNetwork(network);
    // Both mainnet and forknet use root datadir, other networks use subdirs
    final networkDir = filePath([
      datadir,
      (network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET || network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET)
          ? ''
          : network.toReadableNet(),
    ]);
    final cookieFile = File(filePath([networkDir, '.cookie']));

    if (cookieFile.existsSync()) {
      try {
        final cookieData = cookieFile.readAsStringSync();
        final parts = cookieData.split(':');
        if (parts.length == 2) {
          username = parts[0];
          password = parts[1];
          log.i('Using cookie auth from ${cookieFile.path}');
        } else {
          throw FormatException('Invalid cookie format');
        }
      } catch (e) {
        log.w('Failed to read cookie file: $e, using defaults');
        username = 'user';
        password = 'password';
      }
    } else {
      // No cookie file, use defaults as last resort
      log.w('No rpcuser/rpcpassword in config and no cookie file found, using defaults');
      username = 'user';
      password = 'password';
    }
  }

  final configFile = confProvider.configPath != null ? path.basename(confProvider.configPath!) : 'config';
  log.i('Using $configFile for mainchain configuration: $username@$host:$port');

  // Merge global + network-specific config values
  final configValues = Map<String, String>.from(config.globalSettings);
  if (config.networkSettings.containsKey(networkSection)) {
    configValues.addAll(config.networkSettings[networkSection]!);
  }

  return CoreConnectionSettings(
    configFile,
    host,
    port,
    username,
    password,
    network,
    configValues,
  );
}
