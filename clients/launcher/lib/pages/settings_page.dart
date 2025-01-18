import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:launcher/env.dart';
import 'package:logger/logger.dart';
import 'package:launcher/widgets/welcome_modal.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:path/path.dart' as path;

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _openWalletStarterDirectory() async {
    final logger = Logger();
    final dataDir = await Environment.datadir();
    final walletStarterDir = path.join(dataDir.path, 'wallet_starters');
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
    final theme = SailTheme.of(context);

    return Container(
      color: theme.colors.background,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary24('Settings'),
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
            ],
          ),
        ],
      ),
    );
  }
}
