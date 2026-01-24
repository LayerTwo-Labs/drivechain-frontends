import 'dart:io';

import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsNetwork extends StatefulWidget {
  const SettingsNetwork({super.key});

  @override
  State<SettingsNetwork> createState() => _SettingsNetworkState();
}

class _SettingsNetworkState extends State<SettingsNetwork> {
  final _settingsProvider = GetIt.I.get<SettingsProvider>();
  BitcoinConfProvider get _confProvider => GetIt.I.get<BitcoinConfProvider>();
  bool _isSelectingDataDir = false;

  @override
  void initState() {
    super.initState();
    _settingsProvider.addListener(setstate);
    _confProvider.addListener(setstate);
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(setstate);
    _confProvider.removeListener(setstate);
    super.dispose();
  }

  void setstate() {
    setState(() {});
  }

  Future<void> _handleNetworkChange(BitcoinNetwork? network) async {
    if (network == null) return;

    if (_confProvider.hasPrivateBitcoinConf) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Network is controlled by your bitcoin.conf file. To change network in bitwindow, delete your own bitcoin.conf file and restart.',
            ),
            backgroundColor: SailTheme.of(context).colors.info,
          ),
        );
      }
      return;
    }

    // swapNetwork() handles everything: datadir check, dialogs, service restart
    await _confProvider.swapNetwork(context, network);
  }

  Future<void> _selectDataDirectory() async {
    setState(() {
      _isSelectingDataDir = true;
    });

    try {
      final defaultDir = BitcoinCore().datadir();

      final result = await FilePicker.platform.getDirectoryPath(
        initialDirectory: defaultDir,
      );
      if (result != null) {
        final testFile = File(path.join(result, '.bitwindow_test'));
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
          await _confProvider.updateDataDir(result);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected directory is not writable: $e'),
                backgroundColor: SailTheme.of(context).colors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting directory: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingDataDir = false;
        });
      }
    }
  }

  Future<void> _clearDataDir() async {
    await _confProvider.updateDataDir(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final showDataDir =
        _confProvider.network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET ||
        _confProvider.network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
        _confProvider.detectedDataDir != null;
    final canEditDataDir = !_confProvider.hasPrivateBitcoinConf;

    return SailColumn(
      spacing: SailStyleValues.padding32,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Network & Node'),
            SailText.secondary13('Configure Bitcoin network and node settings'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Bitcoin Network'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<BitcoinNetwork>(
              value: _confProvider.network,
              enabled: !_confProvider.hasPrivateBitcoinConf,
              items: [
                SailDropdownItem<BitcoinNetwork>(
                  value: BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
                  label: BitcoinNetwork.BITCOIN_NETWORK_MAINNET.toDisplayName(),
                ),
                SailDropdownItem<BitcoinNetwork>(
                  value: BitcoinNetwork.BITCOIN_NETWORK_FORKNET,
                  label: BitcoinNetwork.BITCOIN_NETWORK_FORKNET.toDisplayName(),
                ),
                SailDropdownItem<BitcoinNetwork>(
                  value: BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
                  label: BitcoinNetwork.BITCOIN_NETWORK_SIGNET.toDisplayName(),
                ),
                SailDropdownItem<BitcoinNetwork>(
                  value: BitcoinNetwork.BITCOIN_NETWORK_TESTNET,
                  label: BitcoinNetwork.BITCOIN_NETWORK_TESTNET.toDisplayName(),
                ),
              ],
              onChanged: (BitcoinNetwork? network) async {
                if (network != null && !_confProvider.hasPrivateBitcoinConf) {
                  await _handleNetworkChange(network);
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              !_confProvider.hasPrivateBitcoinConf
                  ? 'Select the Bitcoin network to connect to'
                  : 'Network is controlled by your bitcoin.conf file',
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Bitcoin Conf Configuration'),
            const SailSpacing(SailStyleValues.padding08),
            SailButton(
              label: 'Edit Bitcoin Core Settings',
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 100));
                final router = GetIt.I.get<AppRouter>();
                await router.push(BitcoinConfEditorRoute());
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'Configure your Bitcoin Core conf',
            ),
          ],
        ),
        if (showDataDir)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Bitcoin Data Directory'),
              const SailSpacing(SailStyleValues.padding08),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.border),
                        borderRadius: SailStyleValues.borderRadiusSmall,
                        color: canEditDataDir ? null : theme.colors.backgroundSecondary,
                      ),
                      child: SailText.secondary13(
                        _confProvider.detectedDataDir ?? 'Default directory',
                      ),
                    ),
                  ),
                  if (canEditDataDir) ...[
                    SailButton(
                      label: 'Browse',
                      small: true,
                      loading: _isSelectingDataDir,
                      onPressed: () async => await _selectDataDirectory(),
                    ),
                    if (_confProvider.detectedDataDir != null)
                      SailButton(
                        label: 'Clear',
                        small: true,
                        variant: ButtonVariant.secondary,
                        onPressed: () async => await _clearDataDir(),
                      ),
                  ],
                ],
              ),
              const SailSpacing(4),
              SailText.secondary12(
                canEditDataDir
                    ? 'Directory where Bitcoin data files are stored (2.5TB+ for mainnet)'
                    : 'Data directory is controlled by your bitcoin.conf file',
              ),
            ],
          ),
        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}

class DataDirSelectionDialog extends StatefulWidget {
  const DataDirSelectionDialog({super.key});

  @override
  State<DataDirSelectionDialog> createState() => _DataDirSelectionDialogState();
}

class _DataDirSelectionDialogState extends State<DataDirSelectionDialog> {
  String? selectedPath;
  bool isSelecting = false;

  Future<void> _selectDirectory() async {
    setState(() {
      isSelecting = true;
    });

    try {
      final defaultDir = BitcoinCore().datadir();

      final result = await FilePicker.platform.getDirectoryPath(
        initialDirectory: defaultDir,
      );
      if (result != null) {
        final testFile = File(path.join(result, '.bitwindow_test'));
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
          setState(() {
            selectedPath = result;
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected directory is not writable: $e'),
                backgroundColor: SailTheme.of(context).colors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting directory: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSelecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SailCard(
          title: 'Select Bitcoin Data Directory',
          subtitle:
              'Mainnet requires a Bitcoin Core data directory with the blockchain data (2.5TB+). Select a directory that contains the blocks folder.',
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colors.border),
                  borderRadius: SailStyleValues.borderRadiusSmall,
                ),
                child: SailText.secondary13(
                  selectedPath ?? 'No directory selected',
                ),
              ),
              SailButton(
                label: 'Browse',
                loading: isSelecting,
                onPressed: () async => await _selectDirectory(),
              ),
              SailRow(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: SailStyleValues.padding08,
                children: [
                  SailButton(
                    label: 'Cancel',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => Navigator.of(context).pop(),
                  ),
                  SailButton(
                    label: 'Confirm',
                    disabled: selectedPath == null,
                    onPressed: () async => Navigator.of(context).pop(selectedPath),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
