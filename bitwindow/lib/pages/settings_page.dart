import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
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
            SailText.primary24(
              'Settings',
              bold: true,
            ),
            SailText.secondary13('Manage your BitWindow settings.'),
            const SailSpacing(SailStyleValues.padding10),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),
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
                Expanded(
                  child: _buildContent(),
                ),
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
          children: [
            SailText.primary20('General'),
            SailText.secondary13('Enable or disable debug mode'),
          ],
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
                SailDropdownItem<bool>(
                  value: false,
                  label: 'Disabled',
                ),
                SailDropdownItem<bool>(
                  value: true,
                  label: 'Enabled',
                ),
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
            SailText.secondary12(
              'When enabled, detailed error reporting will be collected to fix bugs hastily.',
            ),
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
  Future<void> _deleteMultisigWallets(Directory dir, Logger logger) async {
    try {
      final entities = await dir.list(recursive: false).toList();

      for (final entity in entities) {
        if (entity is Directory && path.basename(entity.path).startsWith('multisig_')) {
          try {
            await entity.delete(recursive: true);
            logger.i('Deleted multisig wallet: ${entity.path}');
          } catch (e) {
            logger.w('Could not delete multisig wallet ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      logger.e('Error cleaning multisig wallets in ${dir.path}: $e');
    }
  }

  Future<void> _onResetAllChains() async {
    await showDialog(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Reset All Blockchain Data?',
        subtitle:
            'Are you sure you want to reset all blockchain data for bitcoin core, enforcer and bitwindow? This action cannot be undone.',
        confirmButtonVariant: ButtonVariant.destructive,
        onConfirm: () async {
          final binaryProvider = GetIt.I.get<BinaryProvider>();

          final binaries = [
            BitcoinCore(),
            Enforcer(),
            BitWindow(),
          ];

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

          // pop the dialog
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _onResetWallet() async {
    await showDialog(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Reset Wallet?',
        subtitle: 'Are you sure you want to reset all wallet data? This will:\n\n'
            '• Permanently delete all wallet files from BitWindow\n'
            '• Permanently delete all wallet files from the Enforcer\n'
            '• Stop all running processes\n'
            '• Return you to the wallet creation screen\n\n'
            'Make sure to backup your seed phrase before proceeding. This action cannot be undone.',
        confirmButtonVariant: ButtonVariant.destructive,
        onConfirm: () async {
          final binaryProvider = GetIt.I.get<BinaryProvider>();
          final logger = GetIt.I.get<Logger>();

          try {
            final binaries = [
              BitcoinCore(),
              Enforcer(),
              BitWindow(),
            ];

            final futures = <Future>[];
            for (final binary in binaries) {
              futures.add(binaryProvider.stop(binary));
            }

            await Future.wait(futures);
            await binaryProvider.stopAll();
            await Future.delayed(const Duration(seconds: 3));

            final appDir = await Environment.datadir();

            final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
            if (await walletDir.exists()) {
              await walletDir.delete(recursive: true);
            }

            final enforcer = Enforcer();
            final enforcerDataDirPath = enforcer.datadir();
            final enforcerWalletDir = Directory(path.join(enforcerDataDirPath, 'wallet'));

            if (await enforcerWalletDir.exists()) {
              await enforcerWalletDir.delete(recursive: true);
            }

            // Clean up bitdrive directory containing multisig data
            final bitdriveDir = Directory(path.join(appDir.path, 'bitdrive'));
            if (await bitdriveDir.exists()) {
              await bitdriveDir.delete(recursive: true);
            }

            // Clean up Bitcoin Core wallet directories in Drivechain/signet
            final dataDir = BitcoinCore().datadir();
            final bitcoinCoreSignetDir = Directory(path.join(dataDir, 'signet'));
            if (await bitcoinCoreSignetDir.exists()) {
              await _deleteMultisigWallets(bitcoinCoreSignetDir, logger);
            }

            // Clean up any additional wallet directories in app directory
            final appDirContents = appDir.listSync();
            for (final entity in appDirContents) {
              if (entity is Directory) {
                final dirName = path.basename(entity.path);
                if (dirName.contains('wallet') || dirName.startsWith('wallet_starters-')) {
                  try {
                    await entity.delete(recursive: true);
                  } catch (e) {
                    logger.w('Could not delete directory $dirName: $e');
                  }
                }
              }
            }

            if (context.mounted) Navigator.of(context).pop();

            if (context.mounted) {
              await GetIt.I.get<AppRouter>().push(CreateWalletRoute());
              unawaited(bootBinaries(GetIt.I.get<Logger>()));
            }
          } catch (e) {
            logger.e('Error during wallet reset: $e');

            if (context.mounted) Navigator.of(context).pop();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error resetting wallet: $e'),
                  backgroundColor: SailTheme.of(context).colors.error,
                ),
              );
            }
          }
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
        SailText.primary20('Reset'),
        SailText.secondary13('Reset all chain data and wallet data.'),
        Row(
          spacing: SailStyleValues.padding12,
          children: [
            SailButton(
              label: 'Reset All Chains',
              variant: ButtonVariant.destructive,
              onPressed: _onResetAllChains,
            ),
            SailButton(
              label: 'Reset Wallet',
              variant: ButtonVariant.destructive,
              onPressed: _onResetWallet,
            ),
          ],
        ),
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
