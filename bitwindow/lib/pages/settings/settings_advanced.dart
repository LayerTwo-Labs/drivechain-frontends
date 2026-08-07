import 'package:flutter/widgets.dart';
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

  Future<void> _onTestSidechainsToggle(bool value) async {
    final confirmed = await showThemedDialog<bool>(
      context: context,
      builder: (dialogContext) => SailAlertCard(
        title: value ? 'Switch to test sidechains?' : 'Switch to production sidechains?',
        subtitle:
            "Switching stops any running layer-2 binaries and removes them from disk. They'll redownload automatically on next start.",
        confirmText: 'Switch',
        onConfirm: () async => Navigator.of(dialogContext).pop(true),
        onCancel: () async => Navigator.of(dialogContext).pop(false),
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _settingsProvider.updateUseTestSidechains(value);
  }

  @override
  Widget build(BuildContext context) {
    return SailSettingsBody(
      children: [
        SailSettingsGroup(
          title: 'Developer options',
          children: [
            if (GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains)
              SailSettingsRow(
                label: 'Test sidechains',
                description: 'Download and run alternative frontends for sidechains',
                trailing: SailToggle(
                  value: _settingsProvider.useTestSidechains,
                  onChanged: _onTestSidechainsToggle,
                ),
              ),
            SailSettingsRow(
              label: 'Paranoid mode',
              description:
                  'Lock chains_config.json. Edit the file by hand to change download URLs or versions. Takes effect on next launch.',
              trailing: SailToggle(
                value: _settingsProvider.bitwindowSettings.paranoidMode,
                onChanged: (value) async {
                  await _settingsProvider.updateParanoidMode(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
