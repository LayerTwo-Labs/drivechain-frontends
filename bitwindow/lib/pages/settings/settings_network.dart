import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  CoreVariantProvider get _variantProvider => GetIt.I.get<CoreVariantProvider>();
  bool _isSelectingDataDir = false;

  @override
  void initState() {
    super.initState();
    _settingsProvider.addListener(setstate);
    _confProvider.addListener(setstate);
    _variantProvider.addListener(setstate);
    // Pick up live edits to chains_config.json since the last refresh.
    _variantProvider.refresh();
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(setstate);
    _confProvider.removeListener(setstate);
    _variantProvider.removeListener(setstate);
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

    await swapNetworkWithDatadirPrompt(context, _confProvider, network);
  }

  Future<void> _selectDataDirectory() async {
    setState(() {
      _isSelectingDataDir = true;
    });

    try {
      final result = await FilePicker.getDirectoryPath(
        initialDirectory: _confProvider.detectedDataDir,
      );
      if (result != null) {
        // Backend validates writability via the RPC.
        await _confProvider.updateDataDir(result);
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

  Future<void> _handleVariantChange(String? id) async {
    if (id == null || id == _variantProvider.activeId) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch Bitcoin Core variant?'),
        content: const Text(
          'Bitcoin Core will be stopped, the new build downloaded if needed, and then restarted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _variantProvider.setVariant(id);
    if (!mounted) return;
    final err = _variantProvider.lastError;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to switch Core variant: $err'),
          backgroundColor: SailTheme.of(context).colors.error,
        ),
      );
    }
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
        if (_variantProvider.isVisible)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Bitcoin Core Variant'),
              const SailSpacing(SailStyleValues.padding08),
              SailDropdownButton<String>(
                value: _variantProvider.activeId,
                enabled: !_variantProvider.busy,
                items: _variantProvider.variants
                    .map(
                      (v) => SailDropdownItem<String>(
                        value: v.id,
                        label: v.installed ? v.displayName : '${v.displayName} (will download)',
                      ),
                    )
                    .toList(),
                onChanged: (String? id) async => _handleVariantChange(id),
              ),
              const SailSpacing(4),
              SailText.secondary12(
                'Choose which Bitcoin Core build the orchestrator runs',
              ),
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

/// Wraps a network swap with a datadir prompt. If the backend rejects the
/// swap because the target network has no datadir configured, this opens
/// [DataDirSelectionDialog], persists the chosen path, then retries the swap.
Future<void> swapNetworkWithDatadirPrompt(
  BuildContext context,
  BitcoinConfProvider provider,
  BitcoinNetwork network,
) async {
  try {
    await provider.swapNetwork(context, network);
  } on MissingDatadirException catch (e) {
    if (!context.mounted) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => DataDirSelectionDialog(network: e.network),
    );
    if (selected == null || selected.isEmpty) return;
    await provider.updateDataDir(selected, forNetwork: e.network);
    if (!context.mounted) return;
    await provider.swapNetwork(context, network);
  }
}

class DataDirSelectionDialog extends StatefulWidget {
  final BitcoinNetwork? network;
  const DataDirSelectionDialog({super.key, this.network});

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
      final result = await FilePicker.getDirectoryPath();
      if (result != null) {
        setState(() {
          selectedPath = result;
        });
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

  String _subtitle() {
    switch (widget.network) {
      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
        return 'Mainnet needs a Bitcoin Core data directory with the blockchain data (2.5TB+). Pick a directory that contains the blocks folder.';
      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        return 'Forknet needs a data directory to store the chain. Pick an empty directory or one already used for forknet.';
      default:
        return 'Pick a directory for Bitcoin Core to store its data.';
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
          subtitle: _subtitle(),
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
