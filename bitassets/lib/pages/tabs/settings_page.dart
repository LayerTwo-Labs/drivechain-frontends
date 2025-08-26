import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bitassets/gen/version.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/sidechain_main.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SettingsTabPage extends StatefulWidget {
  const SettingsTabPage({super.key});

  @override
  State<SettingsTabPage> createState() => _SettingsTabPageState();
}

class _SettingsTabPageState extends State<SettingsTabPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding10,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            SailText.primary24('Settings', bold: true),
            SailText.secondary13('Manage your BitAssets settings.'),
            const SailSpacing(SailStyleValues.padding10),
            Divider(height: 1, thickness: 1, color: theme.colors.divider),
            const SailSpacing(SailStyleValues.padding10),

            // Navigation and Content side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left navigation
                SideNav(
                  items: const [
                    SideNavItem(label: 'General'),
                    SideNavItem(label: 'Reset'),
                    SideNavItem(label: 'Info'),
                  ],
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
                const SailSpacing(SailStyleValues.padding40),
                // Right content area
                Expanded(child: _buildContent()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _GeneralSettingsContent();
      case 1:
        return _ResetSettingsContent();
      case 2:
        return _InfoSettingsContent();
      default:
        return _GeneralSettingsContent();
    }
  }
}

class _GeneralSettingsContent extends StatefulWidget {
  @override
  State<_GeneralSettingsContent> createState() => _GeneralSettingsContentState();
}

class _GeneralSettingsContentState extends State<_GeneralSettingsContent> {
  final _clientSettings = GetIt.I<ClientSettings>();
  bool _debugMode = false;

  @override
  void initState() {
    super.initState();
    _loadDebugMode();
  }

  Future<void> _loadDebugMode() async {
    final setting = DebugModeSetting();
    final loadedSetting = await _clientSettings.getValue(setting);
    setState(() {
      _debugMode = loadedSetting.value;
    });
  }

  Future<void> _showDebugModeWarning() async {
    await showDialog(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Enable Debug Mode?',
        subtitle:
            'Enabling debug mode will send detailed error reports Sentry.\r\n\r\nEvery time a component crashes or an error is thrown, '
            'Sentry will collect technical information about your device, app usage patterns, and error details.'
            '\r\n\r\nIt is very helpful to the devs, but it also includes information such as your IP address, device type, and location. '
            'If you dont trust Sentry with this information, enable a VPN, or press Cancel.',
        onConfirm: () async {
          await _clientSettings.setValue(DebugModeSetting(newValue: true));
          setState(() => _debugMode = true);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile section header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SailText.primary20('General'), SailText.secondary13('Enable or disable debug mode')],
        ),

        // Debug Mode Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Debug Mode'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<bool>(
              value: _debugMode,
              items: [
                SailDropdownItem<bool>(value: false, label: 'Disabled'),
                SailDropdownItem<bool>(value: true, label: 'Enabled'),
              ],
              onChanged: (bool? newValue) async {
                if (newValue == true) {
                  await _showDebugModeWarning();
                } else {
                  await _clientSettings.setValue(DebugModeSetting(newValue: false));
                  setState(() => _debugMode = false);
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12('When enabled, detailed error reporting will be collected to fix bugs hastily.'),
          ],
        ),
      ],
    );
  }
}

class _ResetSettingsContent extends StatefulWidget {
  @override
  State<_ResetSettingsContent> createState() => _ResetSettingsContentState();
}

class _ResetSettingsContentState extends State<_ResetSettingsContent> {
  Future<void> _onResetAllChains() async {
    await showDialog(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Reset All Blockchain Data?',
        subtitle:
            'Are you sure you want to reset all blockchain data for bitassets? Wallets are not touched. This action cannot be undone.',
        confirmButtonVariant: ButtonVariant.destructive,
        onConfirm: () async {
          final binaryProvider = GetIt.I.get<BinaryProvider>();

          final binary = BitAssets();

          // Only stop binaries that are started by bitwindow
          await binaryProvider.stop(binary);
          // After all binaries are asked nicely to stop, kill any lingering processes just in case
          await binaryProvider.stopAll();
          // wait for 3 seconds to ensure bitassets is dead
          await Future.delayed(const Duration(seconds: 3));

          // wipe all chain data
          await binary.wipeAppDir();

          // finally, boot the binaries
          bootBinaries(GetIt.I.get<Logger>(), binaryProvider.binaries.firstWhere((b) => b is BitAssets));

          final rpc = GetIt.I.get<BitAssetsRPC>();
          while (!rpc.connected) {
            await Future.delayed(const Duration(seconds: 1));
          }

          // pop the dialog
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SailText.primary20('Reset'), SailText.secondary13('Reset blockchain data')],
        ),
        SailButton(label: 'Reset BitAssets Data', variant: ButtonVariant.destructive, onPressed: _onResetAllChains),
      ],
    );
  }
}

class _InfoSettingsContent extends StatefulWidget {
  @override
  State<_InfoSettingsContent> createState() => _InfoSettingsContentState();
}

class _InfoSettingsContentState extends State<_InfoSettingsContent> {
  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SailText.primary20('Info'), SailText.secondary13('Application version and build information')],
        ),

        // Version Information
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Version'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.versionString),
          ],
        ),

        // Build Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Build Date'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.buildDate),
          ],
        ),

        // Commit Hash
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Commit'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.commitFull),
          ],
        ),

        // App Name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Application'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.appName),
          ],
        ),
      ],
    );
  }
}
