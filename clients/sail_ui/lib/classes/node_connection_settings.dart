import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';

class NodeConnectionSettings extends ChangeNotifier {
  /// On local networks (i.e. regtest, simnet) we can mine blocks
  /// on the mainchain and activate new sidechains. That's NOT
  /// possible on global networks.
  late final bool isLocalNetwork;

  final configPathController = TextEditingController();
  final hostController = TextEditingController();
  final portController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String get host => hostController.text;
  int get port => int.tryParse(portController.text) ?? 0;
  String get username => usernameController.text;
  String get password => passwordController.text;
  final ssl = false;

  String? readError;

  late String confPath;
  late String fileHost;
  late int filePort;
  late String fileUsername;
  late String filePassword;
  bool get inputDifferentThanFile =>
      configPathController.text != confPath ||
      hostController.text != fileHost ||
      portController.text != filePort.toString() ||
      usernameController.text != fileUsername ||
      passwordController.text != filePassword;

  // Add a map to store arbitrary config values
  final Map<String, String> configValues = {};

  NodeConnectionSettings(
    String path,
    String host,
    int port,
    String username,
    String password,
    bool localNetwork, [
    Map<String, String>? additionalConfig,
  ]) {
    _setFileValues(path, host, port, username, password);
    isLocalNetwork = localNetwork;
    if (additionalConfig != null) {
      configValues.addAll(additionalConfig);
    }

    configPathController.text = path;
    hostController.text = host;
    portController.text = port.toString();
    usernameController.text = username;
    passwordController.text = password;

    configPathController.addListener(notifyListeners);
    hostController.addListener(notifyListeners);
    portController.addListener(notifyListeners);
    usernameController.addListener(notifyListeners);
    passwordController.addListener(notifyListeners);
  }

  void _setFileValues(String path, String host, int port, String username, String password) {
    confPath = path;
    fileHost = host;
    filePort = port;
    fileUsername = username;
    filePassword = password;
  }

  void resetToFileValues() {
    configPathController.text = confPath;
    hostController.text = fileHost;
    portController.text = filePort.toString();
    usernameController.text = fileUsername;
    passwordController.text = filePassword;

    notifyListeners();
  }

  void readAndSetValuesFromFile(Binary chain, String network) async {
    try {
      var parts = splitPath(configPathController.text);
      String dataDir = parts.$1;
      String confFile = parts.$2;
      readError = null;

      final config = await readRPCConfig(dataDir, confFile, chain, network);
      configPathController.text = config.confPath;
      hostController.text = config.host;
      portController.text = config.port.toString();
      usernameController.text = config.username;
      passwordController.text = config.password;

      _setFileValues(
        config.confPath,
        config.host,
        config.port,
        config.username,
        config.password,
      );
    } catch (error) {
      readError = error.toString();
    }

    notifyListeners();
  }

  (String, String) splitPath(String path) {
    final sep = Platform.pathSeparator;
    if (!path.contains(sep)) {
      return ('', '');
    }
    String directory = path.substring(0, path.lastIndexOf(sep));
    String fileName = path.split(sep).last;

    return (directory, fileName);
  }

  @override
  void dispose() {
    super.dispose();
    configPathController.removeListener(notifyListeners);
    hostController.removeListener(notifyListeners);
    portController.removeListener(notifyListeners);
    usernameController.removeListener(notifyListeners);
    passwordController.removeListener(notifyListeners);
  }

  static NodeConnectionSettings empty() {
    return NodeConnectionSettings('', '', 0, '', '', false, {});
  }

  // Add method to get config value
  String? getConfigValue(String key) => configValues[key];

  // Add method to set config value
  void setConfigValue(String key, String value) {
    configValues[key] = value;
    notifyListeners();
  }

  // Add method to read all values from conf file
  void readConfigFromFile(List<String> lines) {
    configValues.clear();
    for (final line in lines) {
      if (line.startsWith('#') || !line.contains('=')) continue;

      final parts = line.split('=');
      if (parts.length != 2) continue;

      final key = parts[0].trim();
      final value = parts[1].trim();

      // Handle special cases
      switch (key) {
        case 'rpcuser':
          usernameController.text = value;
          break;
        case 'rpcpassword':
          passwordController.text = value;
          break;
        case 'rpcport':
          portController.text = value;
          break;
        default:
          configValues[key] = value;
      }
    }
    notifyListeners();
  }

  List<String> getConfigArgs() {
    final args = <String>[];
    configValues.forEach((key, value) {
      args.add('-$key=$value');
    });
    return args;
  }
}

// This gets overwritten at a later point, just here to make the
// type system happy.
final _emptyNodeConf = NodeConnectionSettings.empty();

Future<NodeConnectionSettings> findSidechainConf(Sidechain chain, String network) async {
  NodeConnectionSettings conf = _emptyNodeConf;

  switch (chain) {
    case TestSidechain():
      try {
        conf = await readRPCConfig(
          TestSidechain().datadir(),
          TestSidechain().confFile(),
          TestSidechain(),
          network,
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;
    case EthereumSidechain():
      try {
        conf = await readRPCConfig(
          EthereumSidechain().datadir(),
          EthereumSidechain().confFile(),
          EthereumSidechain(),
          network,
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;
    case ZCashSidechain():
      try {
        conf = await readRPCConfig(
          ZCashSidechain().datadir(),
          ZCashSidechain().confFile(),
          ZCashSidechain(),
          'regtest',
          useCookieAuth: false,
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;

    case ParentChain():
      // do absolutely nothing, not a sidechain!
      break;
  }

  return conf;
}
