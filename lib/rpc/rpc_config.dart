import 'dart:io';

import 'package:collection/collection.dart';
import 'package:sidesail/logger.dart';

class Config {
  final String host;
  final int port;
  final String username;
  final String password;

  const Config({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });
}

// TODO: add signet support
const network = 'regtest';

// Order of precedence:
//
// 1. Conf file
// 2. Inspect cookie
// 3. Defaults
//
Future<Config> readRpcConfig(String datadir, String confFile) async {
  final networkDir = _filePath([datadir, network]);

  final conf = File(_filePath([datadir, confFile]));

  final cookie = File(_filePath([networkDir, '.cookie']));

  String? username;
  String? password;
  String? host;
  int? port;

  if (!await conf.exists() && !await cookie.exists()) {
    throw 'could not find neither conf ($conf) nor cookie ($cookie)';
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
  port ??= confFile.startsWith('testchain') ? _defaultSidechainPorts[network]! : _defaultMainchainPorts[network]!;

// Make sure to not include password here
  log.i('resolved conf: $username@$host:$port');
  return Config(
    host: host,
    port: port,
    username: username,
    password: password,
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
    return _filePath([
      home,
      '.drivechain',
    ]);
  } else if (Platform.isMacOS) {
    return _filePath([
      home,
      'Library',
      'Application Support',
      'Drivechain',
    ]);
  } else if (Platform.isWindows) {
    throw 'TODO: windows';
  } else {
    throw 'unsupported operating system: ${Platform.operatingSystem}';
  }
}

// TODO: make this configurable when adding support for more sidechains
// TODO: this might need permissions configuration for Windows and Linux?
String testchainDatadir() {
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']; // windows!
  if (home == null) {
    throw 'unable to determine HOME location';
  }

  if (Platform.isLinux) {
    return _filePath([
      home,
      '.testchain',
    ]);
  } else if (Platform.isMacOS) {
    return _filePath([
      home,
      'Library',
      'Application Support',
      'Testchain',
    ]);
  } else if (Platform.isWindows) {
    throw 'TODO: windows';
  } else {
    throw 'unsupported operating system: ${Platform.operatingSystem}';
  }
}

String _filePath(List<String> segments) {
  return segments.where((element) => element.isNotEmpty).join(Platform.pathSeparator);
}

// TODO: this would need to take chain into account
// TODO: add more nets
Map<String, int> _defaultSidechainPorts = {
  'regtest': 18743,
};

// TODO: add more nets
Map<String, int> _defaultMainchainPorts = {
  'regtest': 18443,
};
