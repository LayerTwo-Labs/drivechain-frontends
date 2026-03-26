import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsAdvanced extends StatefulWidget {
  const SettingsAdvanced({super.key});

  @override
  State<SettingsAdvanced> createState() => _SettingsAdvancedState();
}

class _SettingsAdvancedState extends State<SettingsAdvanced> {
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
            SailText.primary20('Advanced'),
            SailText.secondary13('Developer options and experimental features'),
          ],
        ),
        // Only show Test Sidechains option on networks that support sidechains
        if (GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Test Sidechains'),
              const SailSpacing(SailStyleValues.padding08),
              SailToggle(
                label: 'Use Test Sidechains',
                value: _settingsProvider.useTestSidechains,
                onChanged: (value) async {
                  await _settingsProvider.updateUseTestSidechains(value);
                },
              ),
              const SailSpacing(4),
              SailText.secondary12(
                'Download and run alternative frontends for sidechains',
              ),
            ],
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Paranoid Mode'),
            const SailSpacing(SailStyleValues.padding08),
            SailToggle(
              label: 'Lock chains_config.json',
              value: _settingsProvider.bitwindowSettings.paranoidMode,
              onChanged: (value) async {
                await _settingsProvider.updateParanoidMode(value);
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'Prevent automatic updates to chains_config.json. You must manually edit the file to change download URLs or versions. Takes effect on next launch.',
            ),
          ],
        ),
        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}
