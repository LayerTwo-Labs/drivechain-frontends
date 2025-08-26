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
NodeConnectionSettings readRPCConfig(
  String datadir,
  String confFile,
  Binary chain,
  String network, {
  // if set, will force this network, irregardless of runtime argument
  bool useCookieAuth = true,
}) {
  final log = GetIt.I.get<Logger>();

  final conf = File(filePath([datadir, confFile]));
  // Mainnet == empty string, special datadirs only apply to non-mainnet
  final networkDir = filePath([datadir, network == 'mainnet' ? '' : network]);

  final cookie = File(filePath([networkDir, '.cookie']));

  var settings = NodeConnectionSettings(conf.path, '127.0.0.1', chain.port, 'user', 'password', network == 'regtest');

  if (conf.existsSync()) {
    log.i('rpc: reading conf file at $conf');
    final confContent = conf.readAsStringSync();
    final lines = confContent.split('\n').map((e) => e.trim()).toList();

    // Read all config values, overwrite
    // default 'host' 'port' 'user' 'password' if set
    settings.readConfigFromFile(lines);

    return settings;
  }

  if (useCookieAuth && cookie.existsSync()) {
    final data = cookie.readAsStringSync();
    final parts = data.split(':');
    if (parts.length != 2) {
      throw 'unexpected cookie file: $data';
    }
    final [username, password] = parts;

    // Make sure to not include password here
    log.t('rpc: read password from cookie file at $cookie');
    log.i('resolved conf: $username@${settings.host}:${settings.port} on $network');
    return NodeConnectionSettings(conf.path, settings.host, settings.port, username, password, network == 'regtest');
  }

  log.i('missing both conf ($conf) and cookie ($cookie), returning default settings');
  return settings;
}

List<String> bitcoinCoreBinaryArgs(NodeConnectionSettings conf) {
  // Only include non-config args in the base args
  final args = [
    conf.isLocalNetwork ? '-regtest' : '',
    conf.username.isNotEmpty && !conf.isFromConfigFile('rpcuser') ? '-rpcuser=${conf.username}' : '',
    conf.password.isNotEmpty && !conf.isFromConfigFile('rpcpassword') ? '-rpcpassword=${conf.password}' : '',
    conf.port != 0 && !conf.isFromConfigFile('rpcport') ? '-rpcport=${conf.port}' : '',
  ];

  // Add all additional config values that aren't from config file
  args.addAll(
    conf.getConfigArgs().where((arg) {
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
