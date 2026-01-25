import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/main.dart';

class SettingsReset extends StatefulWidget {
  const SettingsReset({super.key});

  @override
  State<SettingsReset> createState() => _SettingsResetState();
}

class _SettingsResetState extends State<SettingsReset> {
  Logger get log => GetIt.I.get<Logger>();

  bool _deleteBlockchainData = false;
  bool _deleteSettings = false;
  bool _deleteWalletFiles = false;
  bool _obliterateEverything = false;
  bool _isResetting = false;
  String _status = '';

  bool get _hasSelection => _deleteBlockchainData || _deleteSettings || _deleteWalletFiles || _obliterateEverything;

  void _updateObliterate() {
    _obliterateEverything = _deleteBlockchainData && _deleteSettings && _deleteWalletFiles;
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
          title: 'Delete ZSide Settings',
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
          subtitle: 'Deletes all ZSide data',
          isDestructive: true,
        ),
        const SailSpacing(SailStyleValues.padding16),
        if (_isResetting)
          SailColumn(
            spacing: SailStyleValues.padding08,
            children: [
              const SailCircularProgressIndicator(),
              SailText.secondary13(_status),
            ],
          )
        else
          SailButton(
            label: 'Reset Selected',
            variant: ButtonVariant.destructive,
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
    if (_deleteBlockchainData) actions.add('delete blockchain data');
    if (_deleteSettings) actions.add('delete settings');
    if (_deleteWalletFiles) actions.add('delete wallet files');

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

    setState(() {
      _isResetting = true;
      _status = 'Stopping ZSide...';
    });

    try {
      await _performReset();
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
          _status = '';
        });
      }
    }
  }

  Future<void> _performReset() async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final binary = ZSide();

    setState(() => _status = 'Stopping ZSide...');
    await binaryProvider.stop(binary);
    await Future.delayed(const Duration(seconds: 2));

    if (_deleteBlockchainData) {
      setState(() => _status = 'Deleting blockchain data...');
      try {
        await binary.deleteBlockchainData();
        log.i('Successfully deleted ZSide blockchain data');
      } catch (e) {
        log.e('Could not delete blockchain data: $e');
      }
    }

    if (_deleteSettings) {
      setState(() => _status = 'Deleting settings...');
      try {
        await binary.deleteSettings();
        log.i('Successfully deleted ZSide settings');
      } catch (e) {
        log.e('Could not delete settings: $e');
      }
    }

    if (_deleteWalletFiles) {
      setState(() => _status = 'Deleting wallet files...');
      try {
        await binary.deleteWallet();
        log.i('Successfully deleted ZSide wallet files');
      } catch (e) {
        log.e('Could not delete wallet files: $e');
      }
    }

    setState(() => _status = 'Restarting ZSide...');
    bootBinaries(log);

    final zsideRPC = GetIt.I.get<ZSideRPC>();
    while (!zsideRPC.connected) {
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() => _status = 'Reset complete!');
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
