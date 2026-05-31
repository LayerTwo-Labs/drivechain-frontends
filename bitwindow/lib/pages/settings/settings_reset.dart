import 'dart:io';

import 'package:bitwindow/pages/root_page.dart' show setRootPageNavigatingAway;
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
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

    final binariesToReset = [
      ...coreBinaries,
      if (_alsoResetSidechains) ...sidechainBinaries,
    ];

    // One deletion spec per binary. Bitcoin Core's wallet is never wiped; every
    // other binary's wallet is moved to wallet_backups/ server-side. The
    // orchestrator gathers the paths and performs the delete.
    final request = [
      for (final binary in binariesToReset)
        SingleDeletion(
          binary: binary.type,
          deletions: <DeletionType>[
            if (_deleteNodeSoftware) DeletionType.DELETION_TYPE_SOFTWARE,
            if (_deleteBlockchainData) DeletionType.DELETION_TYPE_DATA,
            if (_deleteSettings) DeletionType.DELETION_TYPE_SETTINGS,
            if (_deleteLogs) DeletionType.DELETION_TYPE_LOGS,
            if (_deleteWalletFiles && binary.type != BinaryType.BINARY_TYPE_BITCOIND) DeletionType.DELETION_TYPE_WALLET,
          ],
        ),
    ];

    // Confirmation page gathers the concrete file list and performs deletion.
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResetConfirmationPage(
          request: request,
          appDir: appDir,
          binaryProvider: binaryProvider,
          log: log,
        ),
      ),
    );

    if (!context.mounted) return;

    if (confirmed == true) {
      final needsWalletCreation = _deleteWalletFiles || _obliterateEverything;

      // Clear in-memory wallet state so the create wallet page sees a fresh
      // state. The orchestrator already cleared its own state server-side and
      // moved the wallet files to wallet_backups/.
      if (needsWalletCreation) {
        GetIt.I.get<WalletReaderProvider>().clearState();
      }

      // Reset the checkbox selection so the form returns to its default state.
      setState(() {
        _deleteNodeSoftware = false;
        _deleteBlockchainData = false;
        _deleteLogs = false;
        _deleteWalletFiles = false;
        _deleteSettings = false;
        _alsoResetSidechains = false;
        _obliterateEverything = false;
      });

      if (needsWalletCreation) {
        // Prevent RootPage.dispose() from triggering app shutdown during navigation
        setRootPageNavigatingAway(true);
        final router = GetIt.I.get<AppRouter>();
        await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
      }
    }
  }
}
