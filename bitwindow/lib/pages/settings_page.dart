import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            SailText.secondary13('Manage your BitWindow settings.'),
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
  final _settingsProvider = GetIt.I.get<SettingsProvider>();

  @override
  void initState() {
    super.initState();
    // Listen to settings changes
    _settingsProvider.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {
      // Rebuild when settings change
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
          await _settingsProvider.updateDebugMode(true);
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
              value: _settingsProvider.debugMode,
              items: [
                SailDropdownItem<bool>(value: false, label: 'Disabled'),
                SailDropdownItem<bool>(value: true, label: 'Enabled'),
              ],
              onChanged: (bool? newValue) async {
                if (newValue == true) {
                  await _showDebugModeWarning();
                } else {
                  await _settingsProvider.updateDebugMode(false);
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
  Logger get log => GetIt.I.get<Logger>();
  Directory get bitwindowAppDir => GetIt.I.get<BinaryProvider>().bitwindowAppDir;

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Reset'),
        SailText.secondary13('Start fresh by resetting various data'),
        SailButton(
          label: 'Reset Blockchain Data',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            await _resetBlockchainData(context);
          },
        ),
        SailButton(
          label: 'Delete All Wallets',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => SailAlertCard(
                title: 'Reset Wallet?',
                subtitle:
                    'Are you sure you want to reset all wallet data? This will:\n\n'
                    '• Permanently delete all wallet files from BitWindow\n'
                    '• Permanently delete all wallet files from the Enforcer\n'
                    '• Stop all running processes\n'
                    '• Return you to the wallet creation screen\n\n'
                    'Make sure to backup your seed phrase before proceeding. This action cannot be undone.',
                confirmButtonVariant: ButtonVariant.destructive,
                onConfirm: () async {
                  await _resetWallets(context);
                },
              ),
            );
          },
        ),
        SailButton(
          label: 'Reset Everything',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => SailAlertCard(
                title: 'Reset Everything?',
                subtitle:
                    'Are you sure you want to reset absolutely everything? Even wallets will be deleted. This action cannot be undone.',
                confirmButtonVariant: ButtonVariant.destructive,
                onConfirm: () async {
                  await _resetEverything(context);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _resetBlockchainData(BuildContext context) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final binaries = [BitcoinCore(), Enforcer(), BitWindow()];

    final futures = <Future>[];
    // Only stop binaries that are started by bitwindow
    for (final binary in binaries) {
      futures.add(binaryProvider.stop(binary));
    }

    // Wait for all stop operations to complete
    await Future.wait(futures);

    // After all binaries are asked nicely to stop, kill any lingering processes
    await binaryProvider.stopAll();

    // wait for 3 seconds to ensure all processes are killed
    await Future.delayed(const Duration(seconds: 3));

    // wipe all chain data
    for (final binary in binaries) {
      await binary.wipeAppDir();
    }

    // finally, boot the binaries
    unawaited(bootBinaries(GetIt.I.get<Logger>()));

    final mainchainRPC = GetIt.I.get<MainchainRPC>();
    while (!mainchainRPC.connected) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _resetEverything(BuildContext context) async {
    await _resetWallets(
      context,
      beforeBoot: () async {
        log.i('resetting blockchain data');

        final allBinaries = [BitcoinCore(), Enforcer(), BitWindow(), Thunder(), Bitnames(), BitAssets(), ZSide()];
        // wipe all chain data - don't swallow errors
        try {
          await Future.wait(allBinaries.map((binary) => binary.wipeAppDir()));
          log.i('Successfully wiped all blockchain data');
        } catch (e) {
          log.e('could not reset blockchain data: $e');
        }

        try {
          await Future.wait(allBinaries.map((binary) => binary.wipeAsset(binDir(bitwindowAppDir.path))));
          log.i('Successfully wiped all blockchain data');
        } catch (e) {
          log.e('could not reset blockchain data: $e');
        }
      },
    );

    // pop the dialog
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _resetWallets(BuildContext context, {Future<void> Function()? beforeBoot}) async {
    final logger = GetIt.I.get<Logger>();

    try {
      await GetIt.I.get<WalletProvider>().deleteAllWallets(beforeBoot: beforeBoot);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      logger.e('could not reset wallet data: $e');

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not reset wallets: $e'), backgroundColor: SailTheme.of(context).colors.error),
        );
      }
    }
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
        SailText.primary20('Info'),
        SailText.secondary13('Application version and build information'),

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
