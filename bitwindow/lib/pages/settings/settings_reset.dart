import 'dart:async';
import 'dart:io';

import 'package:bitwindow/main.dart' show bootBinaries;
import 'package:bitwindow/pages/settings_page.dart' show ResetProgressDialog;
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsReset extends StatefulWidget {
  const SettingsReset({super.key});

  @override
  State<SettingsReset> createState() => _SettingsResetState();
}

class _SettingsResetState extends State<SettingsReset> {
  Logger get log => GetIt.I.get<Logger>();
  Directory get appDir => GetIt.I.get<BinaryProvider>().appDir;

  bool _deleteNodeSoftware = false;
  bool _deleteBlockchainData = false;
  bool _deleteWalletFiles = false;
  bool _deleteSettings = false;
  bool _alsoResetSidechains = false;
  bool _obliterateEverything = false;

  bool get _hasSelection =>
      _deleteNodeSoftware || _deleteBlockchainData || _deleteWalletFiles || _deleteSettings || _obliterateEverything;

  void _updateObliterate() {
    _obliterateEverything =
        _deleteNodeSoftware && _deleteBlockchainData && _deleteWalletFiles && _deleteSettings && _alsoResetSidechains;
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Reset'),
        SailText.secondary13('Select what you want to reset and click the button below'),
        const SailSpacing(SailStyleValues.padding08),
        ResetOptionTile(
          value: _deleteNodeSoftware,
          onChanged: (v) => setState(() {
            _deleteNodeSoftware = v;
            _updateObliterate();
          }),
          title: 'Delete Node Software and Data',
          subtitle: 'Deletes all binaries for re-downloading, including logs',
          isDestructive: false,
        ),
        ResetOptionTile(
          value: _deleteBlockchainData,
          onChanged: (v) => setState(() {
            _deleteBlockchainData = v;
            _updateObliterate();
          }),
          title: 'Delete Blockchain Data',
          subtitle: 'Resyncs the blockchain from scratch',
          isDestructive: false,
        ),
        ResetOptionTile(
          value: _deleteSettings,
          onChanged: (v) => setState(() {
            _deleteSettings = v;
            _updateObliterate();
          }),
          title: 'Delete BitWindow Settings',
          subtitle: 'Resets all configuration to defaults',
          isDestructive: false,
        ),
        ResetOptionTile(
          value: _deleteWalletFiles,
          onChanged: (v) => setState(() {
            _deleteWalletFiles = v;
            _updateObliterate();
          }),
          title: 'Delete My Wallet Files',
          subtitle: 'Backup your seed phrase first!',
          isDestructive: true,
        ),
        ResetOptionTile(
          value: _alsoResetSidechains,
          onChanged: (v) => setState(() {
            _alsoResetSidechains = v;
            _updateObliterate();
          }),
          title: 'Reset Sidechain Data',
          subtitle: 'Also wipes all data for Thunder, BitNames, BitAssets and ZSide',
          isDestructive: true,
        ),
        ResetOptionTile(
          value: _obliterateEverything,
          onChanged: (v) => setState(() {
            _obliterateEverything = v;
            _deleteNodeSoftware = v;
            _deleteBlockchainData = v;
            _deleteWalletFiles = v;
            _deleteSettings = v;
            _alsoResetSidechains = v;
          }),
          title: 'Fully Obliterate Everything',
          subtitle: 'Deletes all data including sidechains',
          isDestructive: true,
        ),
        const SailSpacing(SailStyleValues.padding16),
        SailButton(
          label: 'Reset Selected',
          variant: ButtonVariant.destructive,
          skipLoading: true,
          disabled: !_hasSelection,
          onPressed: () async {
            await _executeReset(context);
          },
        ),
      ],
    );
  }

  Future<void> _executeReset(BuildContext context) async {
    final actions = <String>[];
    if (_deleteNodeSoftware) actions.add('delete node software');
    if (_deleteBlockchainData) actions.add('delete blockchain data');
    if (_deleteWalletFiles) actions.add('delete wallet files');
    if (_deleteSettings) actions.add('delete settings');
    if (_alsoResetSidechains) actions.add('reset sidechain data');
    if (_obliterateEverything) actions.add('obliterate everything');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Confirm Reset',
        subtitle: 'This will ${actions.join(', ')}.\n\nThis action cannot be undone.',
        confirmButtonVariant: ButtonVariant.destructive,
        onConfirm: () async {
          Navigator.of(context).pop(true);
        },
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final router = GetIt.I.get<AppRouter>();
    final needsWalletCreation = _deleteWalletFiles || _obliterateEverything;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ResetProgressDialog(
        resetFunction: (updateStatus) async {
          await _performReset(updateStatus);
        },
        onComplete: () async {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    if (!_obliterateEverything) {
      unawaited(bootBinaries(log));
    }

    if (needsWalletCreation) {
      await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
    }
  }

  Future<void> _performReset(void Function(String) updateStatus) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final coreBinaries = [
      BitcoinCore(),
      Enforcer(),
      BitWindow(),
    ];

    final sidechainBinaries = [
      Thunder(),
      Truthcoin(),
      Photon(),
      BitNames(),
      BitAssets(),
      ZSide(),
    ];

    final binariesToReset = [
      ...coreBinaries,
      if (_alsoResetSidechains) ...sidechainBinaries,
    ];

    updateStatus('Stopping binaries');
    await Future.wait(binariesToReset.map((b) => binaryProvider.stop(b)));
    await Future.delayed(const Duration(seconds: 3));

    if (_deleteNodeSoftware) {
      updateStatus('Deleting node software');
      try {
        await Future.wait(binariesToReset.map((b) => b.deleteBinaries(binDir(appDir.path))));
        await copyBinariesFromAssets(log, appDir);
        log.i('Successfully deleted and re-downloaded node software');
      } catch (e) {
        log.e('could not delete node software: $e');
      }
    }

    if (_deleteBlockchainData) {
      updateStatus('Deleting blockchain data');
      try {
        await Future.wait(binariesToReset.map((b) => b.deleteBlockchainData()));
        log.i('Successfully deleted blockchain data');
      } catch (e) {
        log.e('could not delete blockchain data: $e');
      }
    }

    if (_deleteSettings) {
      updateStatus('Deleting settings');
      try {
        await Future.wait(binariesToReset.map((b) => b.deleteSettings()));
        log.i('Successfully deleted settings');
      } catch (e) {
        log.e('could not delete settings: $e');
      }
    }

    if (_deleteWalletFiles) {
      updateStatus('Deleting wallet files');
      try {
        await Future.wait(binariesToReset.map((b) => b.deleteWallet()));
        log.i('Successfully deleted wallet files');
      } catch (e) {
        log.e('could not delete wallet files: $e');
      }
    }

    updateStatus('Reset complete');
  }
}

class ResetOptionTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;
  final bool isDestructive;

  const ResetOptionTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: SailStyleValues.borderRadiusSmall,
      child: Container(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? (isDestructive ? theme.colors.error : theme.colors.primary) : theme.colors.border,
          ),
          borderRadius: SailStyleValues.borderRadiusSmall,
        ),
        child: SailRow(
          spacing: SailStyleValues.padding12,
          children: [
            SailCheckbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13(
                    title,
                    color: isDestructive ? theme.colors.error : null,
                  ),
                  SailText.secondary12(
                    subtitle,
                    color: isDestructive ? theme.colors.error.withValues(alpha: 0.7) : null,
                  ),
                ],
              ),
            ),
            if (isDestructive)
              SailSVG.fromAsset(
                SailSVGAsset.iconWarning,
                color: theme.colors.error,
                width: 20,
                height: 20,
              ),
          ],
        ),
      ),
    );
  }
}
