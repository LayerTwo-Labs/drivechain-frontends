import 'dart:io';

import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/providers/proc_provider.dart';

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
Future<SingleNodeConnectionSettings> readRpcConfig(String datadir, String confFile, Sidechain? sidechain) async {
  final log = GetIt.I.get<Logger>();

  final conf = File(filePath([datadir, confFile]));

  var network = RuntimeArgs.network;

  // Mainnet == empty string, special datadirs only apply to non-mainnet
  final networkDir = filePath([datadir, network == 'mainnet' ? '' : network]);

  final cookie = File(filePath([networkDir, '.cookie']));

  String? username;
  String? password;
  String? host;
  int? port;
  final defaultPort = sidechain?.rpcPort ?? _defaultMainchainPorts[network]!;

  if (!await conf.exists() && !await cookie.exists()) {
    log.d('missing both conf ($conf) and cookie ($cookie), returning default settings');
    return SingleNodeConnectionSettings(
      '',
      'localhost',
      defaultPort,
      'user',
      'password',
      network == 'regtest',
    );
  }

  if (await cookie.exists()) {
    final data = await cookie.readAsString();
    final parts = data.split(':');
    if (parts.length != 2) {
      throw 'unexpected cookie file: $data';
    }
    [username, password] = parts;

    log.t('rpc: read password from cookie file at $cookie');
  }

  if (await conf.exists()) {
    log.t('rpc: reading conf file at $conf');

    final confContent = await conf.readAsString();
    final lines = confContent.split('\n').map((e) => e.trim()).toList();

    username ??= _configValue(lines, 'rpcuser');
    password ??= _configValue(lines, 'rpcpassword');

    final rawPort = _configValue(lines, 'rpcport');
    if (rawPort != null) {
      port = int.parse(rawPort);
    }
  }

  if (password == null || username == null) {
    throw 'could not find username or password in conf file, and cookie was not present';
  }

  host ??= 'localhost';
  port ??= defaultPort;

// Make sure to not include password here
  log.i('resolved conf: $username@$host:$port on $network');
  return SingleNodeConnectionSettings(
    conf.path,
    host,
    port,
    username,
    password,
    network == 'regtest',
  );
}

String? _configValue(List<String> config, String key) {
  final line = config.firstWhereOrNull((element) => element.split('=').first == key);
  return line?.split('=').lastOrNull;
}

// TODO: this might need permissions configuration for Windows and Linux?
String mainchainDatadir() {
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']; // windows!
  if (home == null) {
    throw 'unable to determine HOME location';
  }

  if (Platform.isLinux) {
    return filePath([
      home,
      '.drivechain',
    ]);
  } else if (Platform.isMacOS) {
    return filePath([
      home,
      'Library',
      'Application Support',
      'Drivechain',
    ]);
  } else if (Platform.isWindows) {
    return filePath([
      home,
      'AppData',
      'Roaming',
      'Drivechain',
    ]);
  } else {
    throw 'unsupported operating system: ${Platform.operatingSystem}';
  }
}

List<String> bitcoinCoreBinaryArgs(
  SingleNodeConnectionSettings conf,
) {
  return [
    conf.isLocalNetwork ? '-regtest' : '',
    '-rpcuser=${conf.username}',
    '-rpcpassword=${conf.password}',
    '-rpcport=${conf.port}',
  ]
      // important: empty strings trip up the binary
      .where((arg) => arg.isNotEmpty)
      .toList();
}

Map<String, int> _defaultMainchainPorts = {
  'mainnet': 8883,
  'regtest': 18443,
};
