import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class NodeSettingsTabPage extends StatelessWidget {
  const NodeSettingsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Node Settings',
      subtitle: 'Manage your node connections',
      scrollable: true,
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => NodeConnectionViewModel(),
        builder: ((context, viewModel, child) {
          return SailColumn(
            spacing: SailStyleValues.padding50,
            children: [
              NodeConnectionSettings(
                name: 'Sidechain',
                connected: viewModel.sidechainConnected,
                settings: viewModel.sidechainSettings,
                testConnectionValues: viewModel.reconnectSidechain,
                connectionError: viewModel.sidechainConnectionError,
                readError: viewModel.sidechainFileError,
                loading: viewModel.sidechainBusy,
              ),
              NodeConnectionSettings(
                name: 'Mainchain',
                connected: viewModel.mainchainConnected,
                settings: viewModel.mainchainSettings,
                testConnectionValues: viewModel.reconnectMainchain,
                connectionError: viewModel.mainchainConnectionError,
                readError: viewModel.mainchainFileError,
                loading: viewModel.mainchainBusy,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class NodeConnectionSettings extends ViewModelWidget<NodeConnectionViewModel> {
  final String name;
  final bool connected;
  final SingleNodeConnectionSettings settings;
  final VoidCallback testConnectionValues;
  final String? connectionError;
  final String? readError;
  final bool loading;

  const NodeConnectionSettings({
    super.key,
    required this.name,
    required this.connected,
    required this.settings,
    required this.testConnectionValues,
    required this.connectionError,
    required this.readError,
    required this.loading,
  });

  @override
  Widget build(BuildContext context, NodeConnectionViewModel viewModel) {
    final theme = SailTheme.of(context);
    return SailColumn(
      spacing: SailStyleValues.padding25,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailColumn(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailText.primary15(name),
                SailErrorShadow(
                  enabled: !connected,
                  child: SailSVG.fromAsset(
                    SailSVGAsset.iconGlobe,
                    width: SailStyleValues.iconSizePrimary,
                    color: connected ? theme.colors.success : theme.colors.error,
                  ),
                ),
              ],
            ),
            if (connectionError != null) SailText.secondary12(connectionError!),
            if (readError != null) SailText.secondary12(readError!),
          ],
        ),
        SailTextField(
          label: 'Config path',
          controller: settings.configPathController,
          hintText: '/the/path/to/your/somethingchain.conf',
          suffixWidget: SailTextButton(
            label: 'Read file',
            onPressed: settings.readAndSetValuesFromFile,
          ),
        ),
        SailTextField(
          label: 'Host',
          controller: settings.hostController,
          hintText: 'host',
        ),
        SailTextField(
          label: 'Port',
          controller: settings.portController,
          hintText: 'port',
        ),
        SailTextField(
          label: 'Username',
          controller: settings.usernameController,
          hintText: 'username',
        ),
        SailTextField(
          label: 'Password',
          controller: settings.passwordController,
          hintText: 'password',
        ),
        SailRow(
          spacing: SailStyleValues.padding10,
          children: [
            Expanded(child: Container()),
            SailButton.secondary(
              'Reset to config file values',
              disabled: !settings.inputDifferentThanFile,
              onPressed: () {
                settings.resetToFileValues();
              },
              size: ButtonSize.regular,
            ),
            SailButton.primary(
              'Test connection',
              loading: loading,
              onPressed: () async {
                testConnectionValues();
              },
              size: ButtonSize.regular,
            ),
          ],
        ),
      ],
    );
  }
}

enum ConnectionStatus { connected, unconnected }

class NodeConnectionViewModel extends BaseViewModel {
  SidechainRPC get sideRPC => GetIt.I.get<SidechainRPC>();
  MainchainRPC get mainRPC => GetIt.I.get<MainchainRPC>();

  SingleNodeConnectionSettings get sidechainSettings => sideRPC.connectionSettings;
  SingleNodeConnectionSettings get mainchainSettings => mainRPC.connectionSettings;

  bool get sidechainConnected => sideRPC.connected;
  bool get mainchainConnected => mainRPC.connected;

  String? get sidechainConnectionError => sideRPC.connectionError;
  String? get mainchainConnectionError => mainRPC.connectionError;

  String? get sidechainFileError => sideRPC.connectionSettings.readError;
  String? get mainchainFileError => mainRPC.connectionSettings.readError;

  bool get sidechainBusy => _sidechainBusy;
  bool get mainchainBusy => _mainchainBusy;

  bool _sidechainBusy = false;
  bool _mainchainBusy = false;

  bool get sidechainSettingsDifferent => sideRPC.connectionSettings.inputDifferentThanFile;
  bool get mainchainSettingsDifferent => mainRPC.connectionSettings.inputDifferentThanFile;

  NodeConnectionViewModel() {
    mainRPC.addListener(notifyListeners);
    mainRPC.connectionSettings.addListener(notifyListeners);

    sideRPC.addListener(notifyListeners);
    sideRPC.connectionSettings.addListener(notifyListeners);
  }

  Timer? _connectionTimer;

  void reconnectSidechain() async {
    _sidechainBusy = true;
    notifyListeners();

    await sideRPC.createClient();
    // calling this will propagate the results to the local
    // sidechainConnetced bool
    await sideRPC.testConnection();

    _sidechainBusy = false;
    notifyListeners();
  }

  void reconnectMainchain() async {
    _mainchainBusy = true;
    notifyListeners();

    await mainRPC.createClient();
    // calling this will propagate the results to the local
    // sidechainConnetced bool
    await mainRPC.testConnection();

    _mainchainBusy = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    sideRPC.removeListener(notifyListeners);
    sideRPC.connectionSettings.removeListener(notifyListeners);
    mainRPC.removeListener(notifyListeners);
    mainRPC.connectionSettings.removeListener(notifyListeners);
    super.dispose();
  }
}

class SingleNodeConnectionSettings extends ChangeNotifier {
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

  late String fileConfigPath;
  late String fileHost;
  late int filePort;
  late String fileUsername;
  late String filePassword;
  bool get inputDifferentThanFile =>
      configPathController.text != fileConfigPath ||
      hostController.text != fileHost ||
      portController.text != filePort.toString() ||
      usernameController.text != fileUsername ||
      passwordController.text != filePassword;

  SingleNodeConnectionSettings(
    String path,
    String host,
    int port,
    String username,
    String password,
  ) {
    _setFileValues(path, host, port, username, password);

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
    fileConfigPath = path;
    fileHost = host;
    filePort = port;
    fileUsername = username;
    filePassword = password;
  }

  void resetToFileValues() {
    configPathController.text = fileConfigPath;
    hostController.text = fileHost;
    portController.text = filePort.toString();
    usernameController.text = fileUsername;
    passwordController.text = filePassword;

    notifyListeners();
  }

  void readAndSetValuesFromFile() async {
    try {
      var parts = splitPath(configPathController.text);
      String dataDir = parts.$1;
      String confFile = parts.$2;
      readError = null;

      final config = await readRpcConfig(dataDir, confFile);
      configPathController.text = config.path;
      hostController.text = config.host;
      portController.text = config.port.toString();
      usernameController.text = config.username;
      passwordController.text = config.password;

      _setFileValues(config.path, config.host, config.port, config.username, config.password);
    } catch (error) {
      readError = error.toString();
    }

    notifyListeners();
  }

  (String, String) splitPath(String path) {
    if (!path.contains('/')) {
      return ('', '');
    }
    String directory = path.substring(0, path.lastIndexOf('/'));
    String fileName = path.split('/').last;

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

  static SingleNodeConnectionSettings empty() {
    return SingleNodeConnectionSettings('', '', 0, '', '');
  }
}
