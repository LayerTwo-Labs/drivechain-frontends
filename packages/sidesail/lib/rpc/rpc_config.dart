import 'dart:io';

import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/settings_tab.dart';
import 'package:sidesail/providers/process_provider.dart';
import 'package:sidesail/storage/sail_settings/network_settings.dart';

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
Future<SingleNodeConnectionSettings> readRPCConfig(
  String datadir,
  String confFile,
  Sidechain? sidechain, {
  // if set, will force this network, irregardless of runtime argument
  String? overrideNetwork,
  bool useCookieAuth = true,
}) async {
  final log = GetIt.I.get<Logger>();
  // network parameter is stored in here!
  ClientSettings clientSettings = GetIt.I.get<ClientSettings>();

  final conf = File(filePath([datadir, confFile]));

  // precedence goes like overrideNetwork > runtime args > saved network
  var network =
      overrideNetwork ?? RuntimeArgs.network ?? (await clientSettings.getValue(NetworkSetting())).value.asString();

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

  if (useCookieAuth && await cookie.exists()) {
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

    username = _configValue(lines, 'rpcuser') ?? 'user';
    password = _configValue(lines, 'rpcpassword') ?? 'password';

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

  // args are expected on the form -paramsdir=/home/.zcash
  final newEntry = '-$key=$value';
  log.i('$key not present in conf, adding $newEntry');
  args.add(newEntry);
}

Map<String, int> _defaultMainchainPorts = {
  'mainnet': 8332,
  'regtest': 18443,
};
