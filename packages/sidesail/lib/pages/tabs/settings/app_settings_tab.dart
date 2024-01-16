import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/font_settings.dart';
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
      scrollable: true,
      title: 'Application settings',
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => ThemeSettingsViewModel(),
        builder: ((context, viewModel, child) {
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
                                viewModel.setTheme(SailThemeValues.dark);
                                app.loadTheme(SailThemeValues.dark);
                              },
                              size: ButtonSize.regular,
                              disabled: viewModel.theme == SailThemeValues.dark,
                            ),
                            SailButton.primary(
                              'Light Theme',
                              onPressed: () {
                                viewModel.setTheme(SailThemeValues.light);
                                app.loadTheme(SailThemeValues.light);
                              },
                              size: ButtonSize.regular,
                              disabled: viewModel.theme == SailThemeValues.light,
                            ),
                            SailButton.primary(
                              'System Theme',
                              onPressed: () {
                                viewModel.setTheme(SailThemeValues.platform);
                                app.loadTheme(SailThemeValues.platform);
                              },
                              size: ButtonSize.regular,
                              disabled: viewModel.theme == SailThemeValues.platform,
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
                                viewModel.setFont(SailFontValues.inter);
                              },
                              size: ButtonSize.regular,
                              disabled: viewModel.font == SailFontValues.inter,
                            ),
                            SailButton.primary(
                              'Source Code Pro',
                              onPressed: () {
                                viewModel.setFont(SailFontValues.sourceCodePro);
                              },
                              size: ButtonSize.regular,
                              disabled: viewModel.font == SailFontValues.sourceCodePro,
                            ),
                          ],
                        ),
                        if (viewModel.font != viewModel.fontOnLoad)
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
                value: '${viewModel.datadir}${Platform.pathSeparator}debug.log',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding20),
                child: SailText.primary20('Active chain', bold: true),
              ),
              StaticActionField(
                copyable: true,
                prefixWidget: Padding(
                  padding: const EdgeInsets.only(right: SailStyleValues.padding10),
                  child: SailSVG.icon(SailSVGAsset.iconCopy),
                ),
                value: RuntimeArgs.chain,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding20),
                child: SailText.primary20('Active network', bold: true),
              ),
              StaticActionField(
                copyable: true,
                prefixWidget: Padding(
                  padding: const EdgeInsets.only(right: SailStyleValues.padding10),
                  child: SailSVG.icon(SailSVGAsset.iconCopy),
                ),
                value: RuntimeArgs.network,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ThemeSettingsViewModel extends BaseViewModel {
  ClientSettings get _clientSettings => GetIt.I.get<ClientSettings>();

  ThemeSettingsViewModel() {
    _init();
  }

  String datadir = '';
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
    datadir = await RuntimeArgs.datadir().then((dir) => dir.path);
    notifyListeners();
  }

  void setFont(SailFontValues newFont) async {
    font = newFont;
    await _clientSettings.setValue(FontSetting().withValue(font));
    notifyListeners();
  }
}
