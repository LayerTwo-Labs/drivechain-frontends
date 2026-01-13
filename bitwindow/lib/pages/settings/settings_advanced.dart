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
        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}
