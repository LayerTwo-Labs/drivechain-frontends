import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

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
    return SailColumn(
      spacing: SailStyleValues.padding32,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Appearance'),
            SailText.secondary13('Customize the look and feel of the application'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Theme'),
            const SailSpacing(SailStyleValues.padding08),
            ToggleThemeButton(),
            const SailSpacing(4),
            SailText.secondary12('Switch between light and dark modes'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Font'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<SailFontValues>(
              value: _settingsProvider.font,
              items: [
                SailDropdownItem<SailFontValues>(
                  value: SailFontValues.inter,
                  label: 'Inter',
                ),
                SailDropdownItem<SailFontValues>(
                  value: SailFontValues.ibmMono,
                  label: 'IBM Plex Mono',
                ),
              ],
              onChanged: (SailFontValues? newValue) async {
                if (newValue != null) {
                  await _settingsProvider.updateFont(newValue);
                  if (context.mounted) {
                    final app = SailApp.of(context);
                    await app.loadFont(newValue);
                  }
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12('Choose your preferred font style'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Bitcoin Unit'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<BitcoinUnit>(
              value: _settingsProvider.bitcoinUnit,
              items: [
                SailDropdownItem<BitcoinUnit>(
                  value: BitcoinUnit.btc,
                  label: 'BTC',
                ),
                SailDropdownItem<BitcoinUnit>(
                  value: BitcoinUnit.sats,
                  label: 'Satoshis',
                ),
              ],
              onChanged: (BitcoinUnit? newValue) async {
                if (newValue != null) {
                  await _settingsProvider.updateBitcoinUnit(newValue);
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12('Choose how Bitcoin amounts are displayed'),
          ],
        ),
        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}
