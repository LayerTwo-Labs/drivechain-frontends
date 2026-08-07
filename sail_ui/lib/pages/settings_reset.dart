import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Reset section shared by the sidechain apps; [binary] is the app's chain binary.
class SettingsReset extends StatefulWidget {
  final Binary binary;
  final String appName;

  const SettingsReset({super.key, required this.binary, required this.appName});

  @override
  State<SettingsReset> createState() => _SettingsResetState();
}

class _SettingsResetState extends State<SettingsReset> {
  Logger get log => GetIt.I.get<Logger>();
  Directory get appDir => GetIt.I.get<BinaryProvider>().appDir;

  bool _deleteBlockchainData = false;
  bool _deleteLogs = false;
  bool _deleteSettings = false;
  bool _deleteWalletFiles = false;
  bool _obliterateEverything = false;

  bool get _hasSelection =>
      _deleteBlockchainData || _deleteLogs || _deleteSettings || _deleteWalletFiles || _obliterateEverything;

  void _updateObliterate() {
    _obliterateEverything = _deleteBlockchainData && _deleteLogs && _deleteSettings && _deleteWalletFiles;
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
                  label: '${widget.appName} settings',
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
              ],
            ),
            SailSettingsGroup(
              children: [
                _option(
                  value: _obliterateEverything,
                  onChanged: (v) => setState(() {
                    _obliterateEverything = v;
                    _deleteBlockchainData = v;
                    _deleteLogs = v;
                    _deleteSettings = v;
                    _deleteWalletFiles = v;
                  }),
                  label: 'Obliterate everything',
                  description: 'Deletes all ${widget.appName} data',
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

    // The orchestrator gathers the concrete paths and performs the delete;
    // wallet files are moved to wallet_backups/ server-side, never removed.
    final deletions = <DeletionType>[
      if (_deleteBlockchainData) DeletionType.DELETION_TYPE_DATA,
      if (_deleteSettings) DeletionType.DELETION_TYPE_SETTINGS,
      if (_deleteWalletFiles) DeletionType.DELETION_TYPE_WALLET,
      if (_deleteLogs) DeletionType.DELETION_TYPE_LOGS,
    ];

    await Navigator.of(context).push<bool>(
      sailRoute(
        builder: (_) => ResetConfirmationPage(
          request: [SingleDeletion(binary: widget.binary.type, deletions: deletions)],
          appDir: appDir,
          binaryProvider: binaryProvider,
          log: log,
        ),
      ),
    );
  }
}
