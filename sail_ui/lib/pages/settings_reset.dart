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
                title: 'Delete ${widget.appName} Settings',
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
                  _deleteLogs = v;
                  _deleteSettings = v;
                  _deleteWalletFiles = v;
                }),
                title: 'Fully Obliterate Everything',
                subtitle: 'Deletes all ${widget.appName} data',
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
