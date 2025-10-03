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
  Network network, {
  // if set, will force this network, irregardless of runtime argument
  bool useCookieAuth = true,
}) {
  final log = GetIt.I.get<Logger>();

  final conf = File(filePath([datadir, confFile]));
  // Mainnet == empty string, special datadirs only apply to non-mainnet
  final networkDir = filePath([datadir, network == Network.NETWORK_MAINNET ? '' : network.toReadableNet()]);

  final cookie = File(filePath([networkDir, '.cookie']));

  // Use correct default port based on network
  final defaultPort = switch (network) {
    Network.NETWORK_MAINNET => 8332,
    Network.NETWORK_TESTNET => 18332,
    Network.NETWORK_SIGNET => 38332,
    Network.NETWORK_REGTEST => 18443,
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
    final lines = confContent.split('\n').map((e) => e.trim()).toList();

    // Parse config file
    for (final line in lines) {
      if (line.startsWith('#') || !line.contains('=')) continue;

      final parts = line.split('=');
      if (parts.length != 2) continue;

      final key = parts[0].trim();
      final value = parts[1].trim();

      // Handle special RPC settings
      switch (key) {
        case 'rpcuser':
          username = value;
          configFromFile.add('rpcuser');
          break;
        case 'rpcpassword':
          password = value;
          configFromFile.add('rpcpassword');
          break;
        case 'rpcport':
          port = int.tryParse(value) ?? defaultPort;
          configFromFile.add('rpcport');
          break;
        case 'rpcconnect':
        case 'rpchost':
          host = value;
          configFromFile.add(key);
          break;
        default:
          // Store other config values
          configValues[key] = value;
          configFromFile.add(key);
      }
    }

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

extension NetworkExtensions on Network {
  String toReadableNet() {
    switch (this) {
      case Network.NETWORK_MAINNET:
        return 'mainnet';
      case Network.NETWORK_SIGNET:
        return 'signet';
      case Network.NETWORK_REGTEST:
        return 'regtest';
      case Network.NETWORK_TESTNET:
        return 'testnet';
      case Network.NETWORK_UNSPECIFIED || Network.NETWORK_UNKNOWN:
      default:
        return 'unknown';
    }
  }
}
