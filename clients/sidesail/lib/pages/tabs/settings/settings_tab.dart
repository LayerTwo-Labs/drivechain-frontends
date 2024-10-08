import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/storage/sail_settings/font_settings.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SettingsTabPage extends StatelessWidget {
  const SettingsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailPage(
      title: 'Settings',
      subtitle: 'Manage your node connections and theme',
      scrollable: true,
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => NodeConnectionViewModel(),
        builder: ((context, model, child) {
          return SailColumn(
            spacing: SailStyleValues.padding50,
            children: [
              NodeConnectionSettings(
                name: model.sidechain.rpc.chain.name,
                chain: model.sidechain.rpc.chain,
                connected: model.sidechain.rpc.connected,
                settings: model.sidechain.rpc.conf,
                testConnectionValues: model.reconnectSidechain,
                connectionError: model.sidechain.rpc.connectionError,
                readError: model.sidechain.rpc.conf.readError,
                loading: model._sidechainBusy,
              ),
              NodeConnectionSettings(
                name: 'Parent Chain',
                chain: ParentChain(),
                connected: model.mainRPC.connected,
                settings: model.mainRPC.conf,
                testConnectionValues: model.reconnectMainchain,
                connectionError: model.mainRPC.connectionError,
                readError: model.mainRPC.conf.readError,
                loading: model._mainchainBusy,
              ),
              ViewModelBuilder.reactive(
                viewModelBuilder: () => ThemeSettingsViewModel(),
                builder: ((context, settingsmodel, child) {
                  return SailColumn(
                    spacing: SailStyleValues.padding10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: SailStyleValues.padding20),
                        child: SailText.primary20('Font', bold: true),
                      ),
                      Row(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 640,
                            ),
                            child: SailColumn(
                              spacing: SailStyleValues.padding10,
                              children: [
                                SailRow(
                                  spacing: SailStyleValues.padding15,
                                  children: [
                                    SailButton.primary(
                                      'Inter',
                                      onPressed: () {
                                        settingsmodel.setFont(SailFontValues.inter);
                                      },
                                      size: ButtonSize.regular,
                                      disabled: settingsmodel.font == SailFontValues.inter,
                                    ),
                                    SailButton.primary(
                                      'Source Code Pro',
                                      onPressed: () {
                                        settingsmodel.setFont(SailFontValues.sourceCodePro);
                                      },
                                      size: ButtonSize.regular,
                                      disabled: settingsmodel.font == SailFontValues.sourceCodePro,
                                    ),
                                  ],
                                ),
                                if (settingsmodel.font != settingsmodel.fontOnLoad)
                                  SailText.primary12(
                                    'Must restart app to apply font changes',
                                    color: theme.colors.orangeLight,
                                  ),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                      const SailSpacing(SailStyleValues.padding20),
                      SailText.primary20('Log file', bold: true),
                      SailButton.secondary(
                        'Open Log File',
                        onPressed: settingsmodel.openLogRoute,
                        size: ButtonSize.regular,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: SailText.secondary13(
                          'The application writes logs to this location. When reporting bugs, please include the content of this file.',
                        ),
                      ),
                      StaticActionField(
                        copyable: true,
                        prefixWidget: Padding(
                          padding: const EdgeInsets.only(right: SailStyleValues.padding10),
                          child: SailSVG.icon(SailSVGAsset.iconCopy),
                        ),
                        value: settingsmodel.logdir,
                      ),
                    ],
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class NodeConnectionSettings extends ViewModelWidget<NodeConnectionViewModel> {
  final Chain chain;
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
    required this.chain,
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
            onPressed: () => settings.readAndSetValuesFromFile(chain),
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
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  MainchainRPC get mainRPC => GetIt.I.get<MainchainRPC>();

  bool _sidechainBusy = false;
  bool _mainchainBusy = false;

  NodeConnectionViewModel() {
    mainRPC.addListener(notifyListeners);
    mainRPC.conf.addListener(notifyListeners);

    sidechain.addListener(notifyListeners);
    sidechain.rpc.conf.addListener(notifyListeners);
  }

  Timer? _connectionTimer;

  void reconnectSidechain() async {
    _sidechainBusy = true;
    notifyListeners();

    // calling this will propagate the results to the local
    // sidechainConnected bool
    await sidechain.rpc.testConnection();

    _sidechainBusy = false;
    notifyListeners();
  }

  void reconnectMainchain() async {
    _mainchainBusy = true;
    notifyListeners();

    // calling this will propagate the results to the local
    // mainchainConnected bool
    await mainRPC.testConnection();

    _mainchainBusy = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    sidechain.removeListener(notifyListeners);
    sidechain.rpc.conf.removeListener(notifyListeners);

    mainRPC.removeListener(notifyListeners);
    mainRPC.conf.removeListener(notifyListeners);

    super.dispose();
  }
}

class SingleNodeConnectionSettings extends ChangeNotifier {
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

  void readAndSetValuesFromFile(Chain chain) async {
    try {
      var parts = splitPath(configPathController.text);
      String dataDir = parts.$1;
      String confFile = parts.$2;
      readError = null;

      final config = await readRPCConfig(dataDir, confFile, chain);
      configPathController.text = config.fileConfigPath;
      hostController.text = config.host;
      portController.text = config.port.toString();
      usernameController.text = config.username;
      passwordController.text = config.password;

      _setFileValues(
        config.fileConfigPath,
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

  static SingleNodeConnectionSettings empty() {
    return SingleNodeConnectionSettings('', '', 0, '', '', false);
  }
}

class ThemeSettingsViewModel extends BaseViewModel {
  ClientSettings get _clientSettings => GetIt.I.get<ClientSettings>();
  AppRouter get _router => GetIt.I.get<AppRouter>();

  ThemeSettingsViewModel() {
    _init();
  }

  String logdir = '';
  SailThemeValues theme = SailThemeValues.light;
  SailFontValues font = SailFontValues.inter;
  SailFontValues fontOnLoad = SailFontValues.inter;

  void setTheme(SailThemeValues newTheme) async {
    theme = newTheme;
    await _clientSettings.setValue(ThemeSetting().withValue(theme));
    notifyListeners();
  }

  Future<void> _init() async {
    theme = (await _clientSettings.getValue(ThemeSetting())).value;
    font = (await _clientSettings.getValue(FontSetting())).value;
    fontOnLoad = font;
    final datadir = await RuntimeArgs.datadir().then((dir) => dir.path);
    logdir = '$datadir${Platform.pathSeparator}debug.log';
    notifyListeners();
  }

  void setFont(SailFontValues newFont) async {
    font = newFont;
    await _clientSettings.setValue(FontSetting().withValue(font));
    notifyListeners();
  }

  void openLogRoute() {
    _router.push(
      LogRoute(
        name: 'Sidesail',
        logPath: logdir,
      ),
    );
  }
}
