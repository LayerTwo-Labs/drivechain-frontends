import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/storage/sail_settings/font_settings.dart';
import 'package:sidesail/storage/sail_settings/network_settings.dart';
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
            spacing: SailStyleValues.padding64,
            children: [
              TweakNodeConnectionSettings(
                name: model.sidechain.rpc.chain.name,
                chain: model.sidechain.rpc.chain,
                connected: model.sidechain.rpc.connected,
                settings: model.sidechain.rpc.conf,
                testConnectionValues: model.reconnectSidechain,
                connectionError: model.sidechain.rpc.connectionError,
                readError: model.sidechain.rpc.conf.readError,
                loading: model._sidechainBusy,
              ),
              TweakNodeConnectionSettings(
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
                                  spacing: SailStyleValues.padding16,
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

class TweakNodeConnectionSettings extends ViewModelWidget<NodeConnectionViewModel> {
  final Binary chain;
  final String name;
  final bool connected;
  final NodeConnectionSettings settings;
  final VoidCallback testConnectionValues;
  final String? connectionError;
  final String? readError;
  final bool loading;

  const TweakNodeConnectionSettings({
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
            onPressed: () => settings.readAndSetValuesFromFile(chain, viewModel.network),
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

  late String network;

  Future<void> _initNetwork() async {
    final clientSettings = GetIt.I.get<ClientSettings>();
    network = RuntimeArgs.network ?? (await clientSettings.getValue(NetworkSetting())).value.asString();
  }

  NodeConnectionViewModel() {
    mainRPC.addListener(notifyListeners);
    mainRPC.conf.addListener(notifyListeners);

    sidechain.addListener(notifyListeners);
    sidechain.rpc.conf.addListener(notifyListeners);

    _initNetwork();
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
    final logFile = await getLogFile();
    logdir = logFile.path;
    notifyListeners();
  }

  void setFont(SailFontValues newFont) async {
    font = newFont;
    await _clientSettings.setValue(FontSetting().withValue(font));
    notifyListeners();
  }

  void openLogRoute() {
    _router.push(
      SailLogRoute(
        name: 'Sidesail',
        logPath: logdir,
      ),
    );
  }
}
