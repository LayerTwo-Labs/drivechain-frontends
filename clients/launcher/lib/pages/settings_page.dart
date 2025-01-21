import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:launcher/env.dart';
import 'package:launcher/widgets/welcome_modal.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _openWalletStarterDirectory() async {
    final logger = Logger();
    final appDir = await Environment.appDir();
    final walletStarterDir = path.join(appDir.path, 'wallet_starters');
    logger.i('Opening directory: $walletStarterDir');

    if (Platform.isWindows) {
      await Process.run('explorer', [walletStarterDir]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [walletStarterDir]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [walletStarterDir]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    return QtPage(
      child: SailRawCard(
        padding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary24('Settings'),
            const SizedBox(height: 8),
            SailText.secondary13(
              'Configure your Drivechain settings',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SailButton.secondary(
                  'Open Starters Directory',
                  onPressed: _openWalletStarterDirectory,
                  size: ButtonSize.regular,
                ),
                const SizedBox(width: 16),
                SailButton.secondary(
                  'Open Welcome Modal',
                  onPressed: () => showWelcomeModal(context),
                  size: ButtonSize.regular,
                ),
                const SizedBox(width: 16),
                SailButton.secondary(
                  'Delete All Starters',
                  onPressed: () => _showDeleteConfirmation(context, tabsRouter),
                  size: ButtonSize.regular,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, TabsRouter tabsRouter) async {
    final navigator = Navigator.of(context);
    final theme = SailTheme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.backgroundSecondary,
        title: SailText.primary20(
          'Delete Wallet Starters',
          color: Colors.white,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.secondary13(
              'Are you sure you want to delete all wallet starters? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            SailText.primary13(
              'WARNING: If you have not stored your master mnemonic phrase, you will not be able to regenerate your sidechain starters.',
              color: SailColorScheme.red,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SailButton.secondary(
            'Return',
            onPressed: () => navigator.pop(false),
            size: ButtonSize.regular,
          ),
          SailButton.primary(
            'Delete',
            onPressed: () => navigator.pop(true),
            size: ButtonSize.regular,
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final appDir = await Environment.appDir();
        final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));

        if (walletDir.existsSync()) {
          await walletDir.delete(recursive: true);
        }

        // Navigate to overview page
        tabsRouter.setActiveIndex(0);

        // Show welcome modal
        if (navigator.mounted) {
          await showWelcomeModal(navigator.context);
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error deleting wallet starters: $e'),
            backgroundColor: SailColorScheme.red,
          ),
        );
      }
    }
  }
}
