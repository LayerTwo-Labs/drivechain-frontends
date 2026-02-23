import 'dart:io';

import 'package:bitnames/main.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsReset extends StatefulWidget {
  const SettingsReset({super.key});

  @override
  State<SettingsReset> createState() => _SettingsResetState();
}

class _SettingsResetState extends State<SettingsReset> {
  Logger get log => GetIt.I.get<Logger>();
  Directory get appDir => GetIt.I.get<BinaryProvider>().appDir;

  bool _deleteBlockchainData = false;
  bool _deleteSettings = false;
  bool _deleteWalletFiles = false;
  bool _obliterateEverything = false;

  bool get _hasSelection => _deleteBlockchainData || _deleteSettings || _deleteWalletFiles || _obliterateEverything;

  void _updateObliterate() {
    _obliterateEverything = _deleteBlockchainData && _deleteSettings && _deleteWalletFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary20('Reset'),
              SailText.secondary13('Select what you want to reset and click the button below'),
              const SailSpacing(SailStyleValues.padding08),
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
                title: 'Delete BitNames Settings',
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
                value: _obliterateEverything,
                onChanged: (v) => setState(() {
                  _obliterateEverything = v;
                  _deleteBlockchainData = v;
                  _deleteSettings = v;
                  _deleteWalletFiles = v;
                }),
                title: 'Fully Obliterate Everything',
                subtitle: 'Deletes all BitNames data',
                isDestructive: true,
              ),
            ],
          ),
        ),
        BottomActionBar(
          maxWidth: double.infinity,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
        ),
      ],
    );
  }

  Future<void> _executeReset(BuildContext context) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final binary = BitNames();

    // Collect all file paths that would be deleted
    final filesToDelete = <DeleteItem>[];

    if (_deleteBlockchainData) {
      final paths = await binary.getBlockchainDataPaths();
      filesToDelete.addAll(paths.map((p) => DeleteItem(path: p)));
    }
    if (_deleteSettings) {
      final paths = await binary.getSettingsPaths();
      filesToDelete.addAll(paths.map((p) => DeleteItem(path: p)));
    }
    if (_deleteWalletFiles) {
      final paths = await binary.getWalletPaths();
      filesToDelete.addAll(paths.map((p) => DeleteItem(path: p)));
    }

    if (filesToDelete.isEmpty) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (context) => SailAlertCard(
          title: 'Nothing to Delete',
          subtitle: 'No files found matching your selection.',
          onConfirm: () async => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    if (!context.mounted) return;

    // Show confirmation page with file list - deletion happens inline
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResetConfirmationPage(
          filesToDelete: filesToDelete,
          binariesToReset: [binary],
          appDir: appDir,
          binaryProvider: binaryProvider,
          deleteNodeSoftware: false,
          log: log,
        ),
      ),
    );

    if (!context.mounted) return;

    // If deletion happened, restart binaries
    if (confirmed == true) {
      bootBinaries(log);

      final bitnamesRPC = GetIt.I.get<BitnamesRPC>();
      while (!bitnamesRPC.connected) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
}
