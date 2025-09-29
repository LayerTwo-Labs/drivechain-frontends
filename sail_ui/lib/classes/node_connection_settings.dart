import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class CoreConnectionSettings extends ChangeNotifier {
  // Core connection properties
  final String confPath;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool ssl = false;
  final Network network;

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
  static CoreConnectionSettings empty([Network network = Network.NETWORK_SIGNET]) {
    // Use correct default port based on network
    final defaultPort = switch (network) {
      Network.NETWORK_MAINNET => 8332,
      Network.NETWORK_TESTNET => 18332,
      Network.NETWORK_SIGNET => 38332,
      Network.NETWORK_REGTEST => 18443,
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
    required Network network,
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

CoreConnectionSettings readMainchainConf() {
  final log = GetIt.I.get<Logger>();
  final confProvider = GetIt.I.get<BitcoinConfProvider>();

  // Create empty config with correct network-specific defaults
  CoreConnectionSettings conf = CoreConnectionSettings.empty(confProvider.network);
  try {
    final datadir = BitcoinCore().datadir();
    final confFileName = BitcoinCore().confFile();

    conf = readRPCConfig(datadir, confFileName, BitcoinCore(), confProvider.network);
    log.i('Using $confFileName for mainchain configuration');
  } catch (error) {
    log.e('could not read mainchain conf: $error');
    // Return the network-appropriate default config
  }

  return conf;
}
