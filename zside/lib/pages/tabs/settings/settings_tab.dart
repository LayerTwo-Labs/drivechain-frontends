import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/config/runtime_args.dart';
import 'package:zside/gen/version.dart';
import 'package:zside/main.dart';
import 'package:zside/routing/router.dart';

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
              ViewModelBuilder.reactive(
                viewModelBuilder: () => ThemeSettingsViewModel(),
                builder: ((context, settingsmodel, child) {
                  return SailColumn(
                    spacing: SailStyleValues.padding10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: SailStyleValues.padding20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary20('Font'),
                            SailText.secondary13('Choose your preferred font'),
                          ],
                        ),
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
                                    SailButton(
                                      label: 'Inter',
                                      onPressed: () async {
                                        settingsmodel.setFont(SailFontValues.inter);
                                      },
                                      disabled: settingsmodel.font == SailFontValues.inter,
                                    ),
                                    SailButton(
                                      label: 'IBM Plex Mono',
                                      onPressed: () async {
                                        settingsmodel.setFont(SailFontValues.ibmMono);
                                      },
                                      disabled: settingsmodel.font == SailFontValues.ibmMono,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.primary20('Log file'),
                          SailText.secondary13('View application logs and debugging information'),
                        ],
                      ),
                      SailButton(
                        label: 'Open Log File',
                        onPressed: settingsmodel.openLogRoute,
                        variant: ButtonVariant.secondary,
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
              // App Version Information Section
              SailColumn(
                spacing: SailStyleValues.padding10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: SailStyleValues.padding20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary20('Application Info'),
                        SailText.secondary13('Version and build information'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 640,
                        ),
                        child: SailColumn(
                          spacing: SailStyleValues.padding10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailColumn(
                              spacing: SailStyleValues.padding04,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.primary13('Version'),
                                SailText.secondary13(AppVersion.versionString),
                              ],
                            ),
                            SailColumn(
                              spacing: SailStyleValues.padding04,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.primary13('Build Date'),
                                SailText.secondary13(AppVersion.buildDate),
                              ],
                            ),
                            SailColumn(
                              spacing: SailStyleValues.padding04,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.primary13('Commit'),
                                SailText.secondary13(AppVersion.commitFull),
                              ],
                            ),
                            SailColumn(
                              spacing: SailStyleValues.padding04,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.primary13('Application'),
                                SailText.secondary13(AppVersion.appName),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

enum ConnectionStatus { connected, unconnected }

class NodeConnectionViewModel extends BaseViewModel {
  ZSideRPC get rpc => GetIt.I.get<ZSideRPC>();
  MainchainRPC get mainRPC => GetIt.I.get<MainchainRPC>();

  late Network network;

  Future<void> _initNetwork() async {
    network = GetIt.I.get<BitcoinConfProvider>().network;
  }

  NodeConnectionViewModel() {
    mainRPC.addListener(notifyListeners);
    mainRPC.conf.addListener(notifyListeners);

    rpc.addListener(notifyListeners);

    _initNetwork();
  }

  Timer? _connectionTimer;

  void reconnectSidechain() async {
    notifyListeners();

    // calling this will propagate the results to the local
    // sidechainConnected bool
    await rpc.testConnection();

    notifyListeners();
  }

  void reconnectMainchain() async {
    // calling this will propagate the results to the local
    // mainchainConnected bool
    await mainRPC.testConnection();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    rpc.removeListener(notifyListeners);

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
    final logFile = await getLogFile(await RuntimeArgs.datadir());
    logdir = logFile.path;
    notifyListeners();
  }

  void setFont(SailFontValues newFont) async {
    font = newFont;
    await _clientSettings.setValue(FontSetting().withValue(font));
    notifyListeners();
  }

  Future<void> openLogRoute() async {
    await _router.push(
      LogRoute(
        title: 'ZSide',
        logPath: logdir,
      ),
    );
  }
}
