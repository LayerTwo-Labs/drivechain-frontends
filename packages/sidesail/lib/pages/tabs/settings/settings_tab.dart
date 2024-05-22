import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/font_settings.dart';
import 'package:sidesail/storage/sail_settings/network_settings.dart';
import 'package:sidesail/storage/sail_settings/theme_settings.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SettingsTabPage extends StatelessWidget {
  const SettingsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = SailApp.of(context);
    final theme = SailTheme.of(context);

    return SailPage(
      title: 'Settings',
      subtitle: 'Manage your node connections and theme',
      scrollable: true,
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => NodeConnectionViewModel(),
        builder: ((context, viewModel, child) {
          return SailColumn(
            spacing: SailStyleValues.padding50,
            children: [
              NodeConnectionSettings(
                name: viewModel.sidechain.rpc.chain.name,
                sidechain: viewModel.sidechain.rpc.chain,
                connected: viewModel.sidechain.rpc.connected,
                settings: viewModel.sidechain.rpc.conf,
                testConnectionValues: viewModel.reconnectSidechain,
                connectionError: viewModel.sidechain.rpc.connectionError,
                readError: viewModel.sidechain.rpc.conf.readError,
                loading: viewModel._sidechainBusy,
              ),
              NodeConnectionSettings(
                name: 'Parent Chain',
                connected: viewModel.mainRPC.connected,
                settings: viewModel.mainRPC.conf,
                testConnectionValues: viewModel.reconnectMainchain,
                connectionError: viewModel.mainRPC.connectionError,
                readError: viewModel.mainRPC.conf.readError,
                loading: viewModel._mainchainBusy,
              ),
              ViewModelBuilder.reactive(
                viewModelBuilder: () => ThemeSettingsViewModel(),
                builder: ((context, settingsViewModel, child) {
                  return SailColumn(
                    spacing: SailStyleValues.padding10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary20('Theme', bold: true),
                      Row(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 640,
                            ),
                            child: SailColumn(
                              spacing: SailStyleValues.padding50,
                              children: [
                                SailRow(
                                  spacing: SailStyleValues.padding15,
                                  children: [
                                    SailButton.primary(
                                      'Dark Theme',
                                      onPressed: () {
                                        settingsViewModel.setTheme(SailThemeValues.dark);
                                        app.loadTheme(SailThemeValues.dark);
                                      },
                                      size: ButtonSize.regular,
                                      disabled: settingsViewModel.theme == SailThemeValues.dark,
                                    ),
                                    SailButton.primary(
                                      'Light Theme',
                                      onPressed: () {
                                        settingsViewModel.setTheme(SailThemeValues.light);
                                        app.loadTheme(SailThemeValues.light);
                                      },
                                      size: ButtonSize.regular,
                                      disabled: settingsViewModel.theme == SailThemeValues.light,
                                    ),
                                    SailButton.primary(
                                      'System Theme',
                                      onPressed: () {
                                        settingsViewModel.setTheme(SailThemeValues.platform);
                                        app.loadTheme(SailThemeValues.platform);
                                      },
                                      size: ButtonSize.regular,
                                      disabled: settingsViewModel.theme == SailThemeValues.platform,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
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
                                        settingsViewModel.setFont(SailFontValues.inter);
                                      },
                                      size: ButtonSize.regular,
                                      disabled: settingsViewModel.font == SailFontValues.inter,
                                    ),
                                    SailButton.primary(
                                      'Source Code Pro',
                                      onPressed: () {
                                        settingsViewModel.setFont(SailFontValues.sourceCodePro);
                                      },
                                      size: ButtonSize.regular,
                                      disabled: settingsViewModel.font == SailFontValues.sourceCodePro,
                                    ),
                                  ],
                                ),
                                if (settingsViewModel.font != settingsViewModel.fontOnLoad)
                                  SailText.primary12(
                                    'Must restart app to apply font changes',
                                    customColor: theme.colors.yellow,
                                  ),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding20),
                        child: SailText.primary20('Log file', bold: true),
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
                        value: '${settingsViewModel.datadir}${Platform.pathSeparator}debug.log',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding20),
                        child: SailText.primary20('Active network', bold: true),
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding15,
                        children: [
                          SailButton.primary(
                            'Mainnet',
                            onPressed: () async {
                              await settingsViewModel.setNetwork(SailNetworkValues.mainnet);
                              await app.restartNodes();
                            },
                            size: ButtonSize.regular,
                            disabled: settingsViewModel.network == SailNetworkValues.mainnet,
                          ),
                          SailButton.primary(
                            'Regtest',
                            onPressed: () async {
                              await settingsViewModel.setNetwork(SailNetworkValues.regtest);
                              await app.restartNodes();
                            },
                            size: ButtonSize.regular,
                            disabled: settingsViewModel.network == SailNetworkValues.regtest,
                          ),
                        ],
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
  final Sidechain? sidechain;
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
    this.sidechain,
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
            onPressed: () => settings.readAndSetValuesFromFile(sidechain),
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

  void readAndSetValuesFromFile(Sidechain? sidechain) async {
    try {
      var parts = splitPath(configPathController.text);
      String dataDir = parts.$1;
      String confFile = parts.$2;
      readError = null;

      final config = await readRPCConfig(dataDir, confFile, sidechain);
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

  ThemeSettingsViewModel() {
    _init();
  }

  String datadir = '';
  // default to mainnet!
  SailNetworkValues network = SailNetworkValues.mainnet;
  SailThemeValues theme = SailThemeValues.light;
  SailFontValues font = SailFontValues.inter;
  SailFontValues fontOnLoad = SailFontValues.inter;

  void setTheme(SailThemeValues newTheme) async {
    theme = newTheme;
    await _clientSettings.setValue(ThemeSetting().withValue(theme));
    notifyListeners();
  }

  Future<void> setNetwork(SailNetworkValues newNetwork) async {
    network = newNetwork;
    await _clientSettings.setValue(NetworkSetting().withValue(network));
    notifyListeners();
  }

  Future<void> _init() async {
    theme = (await _clientSettings.getValue(ThemeSetting())).value;
    font = (await _clientSettings.getValue(FontSetting())).value;
    network = (await _clientSettings.getValue(NetworkSetting())).value;
    fontOnLoad = font;
    datadir = await RuntimeArgs.datadir().then((dir) => dir.path);
    notifyListeners();
  }

  void setFont(SailFontValues newFont) async {
    font = newFont;
    await _clientSettings.setValue(FontSetting().withValue(font));
    notifyListeners();
  }
}