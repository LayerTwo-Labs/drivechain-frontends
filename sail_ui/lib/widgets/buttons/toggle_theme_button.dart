import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class ToggleThemeButton extends StatefulWidget {
  const ToggleThemeButton({super.key});

  @override
  State<ToggleThemeButton> createState() => _ToggleThemeButtonState();
}

class _ToggleThemeButtonState extends State<ToggleThemeButton> {
  final _clientSettings = GetIt.I<ClientSettings>();

  _ToggleThemeButtonState();

  SailThemeValues _currentTheme = SailThemeValues.system;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    final app = SailApp.of(context);

    return SailButton(
      variant: ButtonVariant.icon,
      onPressed: () async {
        final SailThemeValues nextTheme = _currentTheme.toggleTheme();
        await setTheme(nextTheme);
        await app.loadTheme(nextTheme);
      },
      icon: themeIcon(_currentTheme),
    );
  }

  SailSVGAsset themeIcon(SailThemeValues currentTheme) {
    SailSVGAsset icon;
    if (currentTheme == SailThemeValues.system) {
      icon = SailSVGAsset.lightDarkMode;
    } else if (currentTheme == SailThemeValues.light) {
      icon = SailSVGAsset.lightMode;
    } else {
      icon = SailSVGAsset.darkMode;
    }

    return icon;
  }

  Future<void> setTheme(SailThemeValues newTheme) async {
    setState(() {
      _currentTheme = newTheme;
    });
    await _clientSettings.setValue(ThemeSetting().withValue(newTheme));
  }

  Future<void> loadTheme() async {
    final themeSetting = await _clientSettings.getValue(ThemeSetting());
    _currentTheme = themeSetting.value;
    setState(() {});
  }
}
