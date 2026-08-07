import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Appearance section shared by every app.
class SettingsAppearance extends StatefulWidget {
  const SettingsAppearance({super.key});

  @override
  State<SettingsAppearance> createState() => _SettingsAppearanceState();
}

class _SettingsAppearanceState extends State<SettingsAppearance> {
  final _settingsProvider = GetIt.I.get<SettingsProvider>();

  @override
  void initState() {
    super.initState();
    _settingsProvider.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SailSettingsBody(
      children: [
        SailSettingsGroup(
          title: 'Theme',
          children: [
            SailSettingsRow(
              label: 'Mode',
              description: 'Switch between light and dark',
              trailing: ToggleThemeButton(),
            ),
            SailSettingsRow(
              label: 'Style',
              description: 'Applies to all clients',
              trailing: SailDropdownButton<SailThemeStyle>(
                value: sailBundleForId(_settingsProvider.bitwindowSettings.themeStyle).style,
                items: sailThemeBundles.values
                    .map((b) => SailDropdownItem<SailThemeStyle>(value: b.style, label: b.displayName))
                    .toList(),
                onChanged: (SailThemeStyle? newValue) async {
                  if (newValue != null) {
                    await _settingsProvider.updateThemeStyle(newValue);
                    if (context.mounted) {
                      await SailApp.of(context).loadStyle(newValue);
                    }
                  }
                },
              ),
            ),
          ],
        ),
        SailSettingsGroup(
          title: 'Text',
          children: [
            SailSettingsRow(
              label: 'Font',
              trailing: SailDropdownButton<SailFontValues>(
                value: _settingsProvider.font,
                items: [
                  SailDropdownItem<SailFontValues>(value: SailFontValues.inter, label: 'Inter'),
                  SailDropdownItem<SailFontValues>(value: SailFontValues.ibmMono, label: 'IBM Plex Mono'),
                ],
                onChanged: (SailFontValues? newValue) async {
                  if (newValue != null) {
                    await _settingsProvider.updateFont(newValue);
                    if (context.mounted) {
                      await SailApp.of(context).loadFont(newValue);
                    }
                  }
                },
              ),
            ),
            SailSettingsRow(
              label: 'Size',
              description: 'Scales text across the whole app',
              trailing: FontSizeSlider(settingsProvider: _settingsProvider),
            ),
          ],
        ),
        SailSettingsGroup(
          title: 'Amounts',
          children: [
            SailSettingsRow(
              label: 'Bitcoin unit',
              description: 'How the app displays bitcoin amounts',
              trailing: SailDropdownButton<BitcoinUnit>(
                value: _settingsProvider.bitcoinUnit,
                items: [
                  SailDropdownItem<BitcoinUnit>(value: BitcoinUnit.btc, label: activeTicker.symbol),
                  SailDropdownItem<BitcoinUnit>(value: BitcoinUnit.sats, label: activeTicker.subunitLabel),
                ],
                onChanged: (BitcoinUnit? newValue) async {
                  if (newValue != null) {
                    await _settingsProvider.updateBitcoinUnit(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
