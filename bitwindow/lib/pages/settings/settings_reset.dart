import 'dart:async';
import 'dart:io';

import 'package:bitwindow/main.dart' show rebootBitwindowBackend;
import 'package:bitwindow/pages/root_page.dart' show setRootPageNavigatingAway;
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
  bool _deleteLogs = false;
  bool _deleteWalletFiles = false;
  bool _deleteSettings = false;
  bool _alsoResetSidechains = false;
  bool _obliterateEverything = false;

  bool get _hasSelection =>
      _deleteNodeSoftware ||
      _deleteBlockchainData ||
      _deleteLogs ||
      _deleteWalletFiles ||
      _deleteSettings ||
      _obliterateEverything;

  void _updateObliterate() {
    _obliterateEverything =
        _deleteNodeSoftware &&
        _deleteBlockchainData &&
        _deleteLogs &&
        _deleteWalletFiles &&
        _deleteSettings &&
        _alsoResetSidechains;
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
                value: _deleteNodeSoftware,
                onChanged: (v) => setState(() {
                  _deleteNodeSoftware = v;
                  _updateObliterate();
                }),
                title: 'Delete Node Software and Data',
                subtitle: 'Deletes all binaries for re-downloading',
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
                value: _deleteLogs,
                onChanged: (v) => setState(() {
                  _deleteLogs = v;
                  _updateObliterate();
                }),
                title: 'Delete Log Files',
                subtitle: 'Removes all debug and server log files',
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
                  _deleteLogs = v;
                  _deleteWalletFiles = v;
                  _deleteSettings = v;
                  _alsoResetSidechains = v;
                }),
                title: 'Fully Obliterate Everything',
                subtitle: 'Deletes all data including sidechains',
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
    final orchestrator = GetIt.I.get<OrchestratorRPC>();

    final binariesToReset = [
      ...coreBinaries,
      if (_alsoResetSidechains) ...sidechainBinaries,
    ];

    // Ask orchestrator what it would delete — server is source of truth.
    final PreviewResetDataResponse preview;
    try {
      preview = await orchestrator.previewResetData(
        deleteNodeSoftware: _deleteNodeSoftware,
        deleteBlockchainData: _deleteBlockchainData,
        deleteLogs: _deleteLogs,
        deleteSettings: _deleteSettings,
        deleteWalletFiles: _deleteWalletFiles,
        alsoResetSidechains: _alsoResetSidechains,
      );
    } catch (e) {
      log.e('previewResetData failed: $e');
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (context) => SailAlertCard(
          title: 'Preview Failed',
          subtitle: 'Could not compute reset preview: $e',
          onConfirm: () async => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    final filesToDelete = preview.files.map((f) => DeleteItem(path: f.path)).toList();

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

    // Show confirmation page with file list - orchestrator performs deletion.
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResetConfirmationPage(
          filesToDelete: filesToDelete,
          binariesToReset: binariesToReset,
          appDir: appDir,
          binaryProvider: binaryProvider,
          deleteNodeSoftware: _deleteNodeSoftware,
          log: log,
          preDeleteAction: _deleteWalletFiles || _obliterateEverything
              ? () => GetIt.I.get<WalletWriterProvider>().deleteAllWallets()
              : null,
          orchestratorDelete: () => orchestrator.streamResetData(
            deleteNodeSoftware: _deleteNodeSoftware,
            deleteBlockchainData: _deleteBlockchainData,
            deleteLogs: _deleteLogs,
            deleteSettings: _deleteSettings,
            deleteWalletFiles: _deleteWalletFiles,
            alsoResetSidechains: _alsoResetSidechains,
          ),
        ),
      ),
    );

    if (!context.mounted) return;

    // If deletion happened, restart binaries
    if (confirmed == true) {
      // Clear in-memory wallet state so the create wallet page sees a fresh state
      if (_deleteWalletFiles || _obliterateEverything) {
        GetIt.I.get<WalletReaderProvider>().clearState();
      }

      unawaited(rebootBitwindowBackend(log));

      final router = GetIt.I.get<AppRouter>();
      final needsWalletCreation = _deleteWalletFiles || _obliterateEverything;

      if (needsWalletCreation) {
        // Prevent RootPage.dispose() from triggering app shutdown during navigation
        setRootPageNavigatingAway(true);
        await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
      }
    }
  }
}
