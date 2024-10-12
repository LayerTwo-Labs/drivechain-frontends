import 'dart:io';

import 'package:flutter/material.dart';
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

  NodeConnectionSettings(
    String path,
    String host,
    int port,
    String username,
    String password,
    bool localNetwork,
  ) {
    _setFileValues(path, host, port, username, password);
    isLocalNetwork = localNetwork;

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

  void readAndSetValuesFromFile(Chain chain, String network) async {
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
    return NodeConnectionSettings('', '', 0, '', '', false);
  }
}

// This gets overwritten at a later point, just here to make the
// type system happy.
final _emptyNodeConf = NodeConnectionSettings.empty();

Future<NodeConnectionSettings> findSidechainConf(Sidechain chain, String network) async {
  NodeConnectionSettings conf = _emptyNodeConf;

  switch (chain.type) {
    case ChainType.testchain:
      try {
        conf = await readRPCConfig(
          TestSidechain().type.datadir(),
          TestSidechain().type.confFile(),
          TestSidechain(),
          network,
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;
    case ChainType.ethereum:
      try {
        conf = await readRPCConfig(
          EthereumSidechain().type.datadir(),
          EthereumSidechain().type.confFile(),
          EthereumSidechain(),
          network,
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;
    case ChainType.zcash:
      try {
        conf = await readRPCConfig(
          ZCashSidechain().type.datadir(),
          ZCashSidechain().type.confFile(),
          ZCashSidechain(),
          'regtest',
          useCookieAuth: false,
        );
      } catch (error) {
        // do nothing, just don't exit
      }
      break;

    case ChainType.parentchain:
      // do absolutely nothing, not a sidechain!
      break;
  }

  return conf;
}
