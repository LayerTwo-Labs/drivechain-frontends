import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class Config {
  final String path;
  final String host;
  final int port;
  final String username;
  final String password;

  const Config({
    required this.path,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });
}

// Order of precedence:
//
// 1. Conf file
// 2. Inspect cookie
// 3. Defaults
//
CoreConnectionSettings readRPCConfig(
  String datadir,
  String confFile,
  Binary chain,
  BitcoinNetwork network, {
  // if set, will force this network, irregardless of runtime argument
  bool useCookieAuth = true,
}) {
  final log = GetIt.I.get<Logger>();

  final conf = File(filePath([datadir, confFile]));
  // Both mainnet and forknet use root datadir, other networks use subdirs
  final networkDir = filePath([
    datadir,
    (network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET || network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET)
        ? ''
        : network.toReadableNet(),
  ]);

  final cookie = File(filePath([networkDir, '.cookie']));

  // Use correct default port based on network
  final defaultPort = switch (network) {
    BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 8332, // real Bitcoin mainnet
    BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 18301, // forknet
    BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 18332,
    BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 38332,
    BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 18443,
    _ => 38332, // fallback to signet for unknown networks
  };

  // Default values
  String host = 'localhost';
  int port = defaultPort;
  String username = 'user';
  String password = 'password';
  Map<String, String> configValues = {};
  Set<String> configFromFile = {};

  if (conf.existsSync()) {
    log.i('rpc: reading conf file at $conf');
    final confContent = conf.readAsStringSync();

    // Parse config with section support
    final config = BitcoinConfig.parse(confContent);
    final networkSection = network.toCoreNetwork();

    // Get effective values (network section overrides global)
    final rpcUser = config.getEffectiveSetting('rpcuser', networkSection);
    if (rpcUser != null) {
      username = rpcUser;
      configFromFile.add('rpcuser');
    }

    final rpcPassword = config.getEffectiveSetting('rpcpassword', networkSection);
    if (rpcPassword != null) {
      password = rpcPassword;
      configFromFile.add('rpcpassword');
    }

    final rpcPortStr = config.getEffectiveSetting('rpcport', networkSection);
    if (rpcPortStr != null) {
      port = int.tryParse(rpcPortStr) ?? defaultPort;
      configFromFile.add('rpcport');
    }

    final rpcHost =
        config.getEffectiveSetting('rpcconnect', networkSection) ??
        config.getEffectiveSetting('rpchost', networkSection);
    if (rpcHost != null) {
      host = rpcHost;
      configFromFile.add('rpchost');
    }

    // Store all config values (global + network-specific merged)
    configValues = Map.from(config.globalSettings);
    if (config.networkSettings.containsKey(networkSection)) {
      configValues.addAll(config.networkSettings[networkSection]!);
    }
    configFromFile.addAll(configValues.keys);

    return CoreConnectionSettings.fromParsedConfig(
      confPath: conf.path,
      host: host,
      port: port,
      username: username,
      password: password,
      network: network,
      configValues: configValues,
      configFromFile: configFromFile,
    );
  }

  if (useCookieAuth && cookie.existsSync()) {
    final data = cookie.readAsStringSync();
    final parts = data.split(':');
    if (parts.length != 2) {
      throw 'unexpected cookie file: $data';
    }
    final [cookieUsername, cookiePassword] = parts;

    // Make sure to not include password here
    log.t('rpc: read password from cookie file at $cookie');
    log.i('resolved conf: $cookieUsername@$host:$port on ${network.toReadableNet()}');
    return CoreConnectionSettings(
      '', // no conf file path when using cookie
      host,
      port,
      cookieUsername,
      cookiePassword,
      network,
      configValues,
    );
  }

  log.i('missing both conf ($conf) and cookie ($cookie), returning default settings');
  return CoreConnectionSettings(
    '',
    host,
    port,
    username,
    password,
    network,
    configValues,
  );
}

List<String> bitcoinCoreBinaryArgs(CoreConnectionSettings conf) {
  // Only include non-config args in the base args
  final args = [
    conf.username.isNotEmpty && !conf.isFromConfigFile('rpcuser') ? '-rpcuser=${conf.username}' : '',
    conf.password.isNotEmpty && !conf.isFromConfigFile('rpcpassword') ? '-rpcpassword=${conf.password}' : '',
  ];

  // Add all additional config values that aren't from config file
  args.addAll(
    conf.getCliConfigArgs().where((arg) {
      final paramName = arg.split('=')[0].replaceFirst('-', '');
      return !conf.isFromConfigFile(paramName);
    }),
  );

  return args.where((arg) => arg.isNotEmpty).toList();
}

// checks if the loaded bitcoin core config contains a specific
// key, e.g:
// # testchain.conf
// regtest=1
//
// confKeyExists(args, 'regtest') => true
bool _confKeyExists(List<String> args, String key) {
  return args.any((arg) => arg.replaceAll('-', '').split('=').first == key);
}

void addEntryIfNotSet(List<String> args, String key, String value) {
  Logger log = GetIt.I.get<Logger>();

  if (_confKeyExists(args, key)) {
    return;
  }

  // args are expected on the form -paramsdir=/home/.zside
  final newEntry = '-$key=$value';
  log.i('$key not present in conf, adding $newEntry');
  args.add(newEntry);
}

extension NetworkExtensions on BitcoinNetwork {
  String toReadableNet() {
    switch (this) {
      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
        return 'mainnet';
      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        return 'forknet';
      case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
        return 'signet';
      case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
        return 'regtest';
      case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
        return 'testnet';
      case BitcoinNetwork.BITCOIN_NETWORK_UNSPECIFIED || BitcoinNetwork.BITCOIN_NETWORK_UNKNOWN:
      default:
        return 'unknown';
    }
  }

  /// Get the config section name for this network
  /// Note: Both mainnet and forknet use 'main' section since forknet runs on mainnet params
  /// and forknet is not a valid Bitcoin Core section
  String toCoreNetwork() {
    switch (this) {
      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        return 'main'; // Forknet uses [main] section - Bitcoin doesn't recognize [forknet]
      case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
        return 'signet';
      case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
        return 'regtest';
      case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
        return 'test';
      case BitcoinNetwork.BITCOIN_NETWORK_UNSPECIFIED || BitcoinNetwork.BITCOIN_NETWORK_UNKNOWN:
      default:
        return 'unknown';
    }
  }

  /// Get the Bitcoin Core section name for Bitcoin Core settings (rpcport, etc.)
  /// Both mainnet and forknet use 'main' for Bitcoin Core compatibility
  String toCoreNetworkForBitcoinSettings() {
    switch (this) {
      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        return 'main';
      case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
        return 'signet';
      case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
        return 'regtest';
      case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
        return 'test';
      case BitcoinNetwork.BITCOIN_NETWORK_UNSPECIFIED || BitcoinNetwork.BITCOIN_NETWORK_UNKNOWN:
      default:
        return 'unknown';
    }
  }
}
