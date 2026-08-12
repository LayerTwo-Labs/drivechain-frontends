import 'dart:io';

import 'package:bitwindow/routing/router.dart';
import 'package:flutter/widgets.dart';
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

  Widget _option({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    required String description,
    bool destructive = false,
  }) {
    return SailSettingsRow(
      leading: SailCheckbox(value: value, onChanged: onChanged),
      label: label,
      description: description,
      destructive: destructive,
      onTap: () => onChanged(!value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SailSettingsBody(
          bottomPadding: 80,
          children: [
            SailSettingsGroup(
              title: 'What to delete',
              description: 'Pick the data to remove, then reset.',
              children: [
                _option(
                  value: _deleteNodeSoftware,
                  onChanged: (v) => setState(() {
                    _deleteNodeSoftware = v;
                    _updateObliterate();
                  }),
                  label: 'Node software',
                  description: 'Deletes all binaries, so they download again',
                ),
                _option(
                  value: _deleteBlockchainData,
                  onChanged: (v) => setState(() {
                    _deleteBlockchainData = v;
                    _updateObliterate();
                  }),
                  label: 'Blockchain data',
                  description: 'Syncs the blockchain again from scratch',
                ),
                _option(
                  value: _deleteLogs,
                  onChanged: (v) => setState(() {
                    _deleteLogs = v;
                    _updateObliterate();
                  }),
                  label: 'Log files',
                  description: 'Removes all debug and server logs',
                ),
                _option(
                  value: _deleteSettings,
                  onChanged: (v) => setState(() {
                    _deleteSettings = v;
                    _updateObliterate();
                  }),
                  label: 'BitWindow settings',
                  description: 'Sets all configuration back to the defaults',
                ),
                _option(
                  value: _deleteWalletFiles,
                  onChanged: (v) => setState(() {
                    _deleteWalletFiles = v;
                    _updateObliterate();
                  }),
                  label: 'Wallet files',
                  description: 'Back up your seed phrase first',
                  destructive: true,
                ),
                _option(
                  value: _alsoResetSidechains,
                  onChanged: (v) => setState(() {
                    _alsoResetSidechains = v;
                    _updateObliterate();
                  }),
                  label: 'Apply to sidechains too',
                  description: 'Deletes the same data for every sidechain',
                ),
              ],
            ),
            SailSettingsGroup(
              children: [
                _option(
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
                  label: 'Obliterate everything',
                  description: 'Selects every option above, sidechains included',
                  destructive: true,
                ),
              ],
            ),
          ],
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
      sailRoute(
        builder: (_) => ResetConfirmationPage(
          request: request,
          appDir: appDir,
          binaryProvider: binaryProvider,
          log: log,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

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
        final router = GetIt.I.get<AppRouter>();
        await router.replaceAll([CreateAnotherWalletRoute()]);
      }
    }
  }
}
