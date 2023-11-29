import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/theme_settings.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ThemeSettingsTabPage extends StatelessWidget {
  const ThemeSettingsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = SailApp.of(context);

    return SailPage(
      title: 'Theme settings',
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => ThemeSettingsViewModel(),
        builder: ((context, viewModel, child) {
          return Row(
            children: [
              Expanded(child: Container()),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 640,
                ),
                child: SailColumn(
                  spacing: SailStyleValues.padding50,
                  children: [
                    SailRow(
                      spacing: SailStyleValues.padding08,
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

  SailThemeValues theme = SailThemeValues.light;

  void setTheme(SailThemeValues newTheme) async {
    theme = newTheme;
    await _clientSettings.setValue(ThemeSetting().withValue(theme));
    notifyListeners();
  }

  Future<void> _init() async {
    theme = (await _clientSettings.getValue(ThemeSetting())).value;
    notifyListeners();
  }
}
