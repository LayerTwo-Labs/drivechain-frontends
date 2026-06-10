import 'package:bitwindow/pages/settings/network_swap_page.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
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
        showSailToast(
          context,
          'Network is controlled by your bitcoin.conf file. To change network in bitwindow, delete your own bitcoin.conf file and restart.',
          variant: SailToastVariant.info,
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
        await _confProvider.updateDataDir(result, forNetwork: _confProvider.network);
        if (!mounted) return;
        await Navigator.of(context).push<bool>(
          sailRoute(
            builder: (_) => const L1RestartPage(
              reason:
                  'Bitcoin Core needs to restart for the new data directory to take effect. The new chain data will be written to the path you just chose.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showSailToast(
          context,
          'Error selecting directory: $e',
          variant: SailToastVariant.destructive,
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
    await _confProvider.updateDataDir(null, forNetwork: _confProvider.network);
  }

  Future<void> _handleVariantChange(String? id) async {
    if (id == null || id == _variantProvider.activeId) return;

    final confirmed = await showThemedDialog<bool>(
      context: context,
      builder: (ctx) => SailDialog(
        title: 'Switch Bitcoin Core variant?',
        actions: [
          SailButton(
            label: 'Cancel',
            variant: ButtonVariant.ghost,
            onPressed: () async => Navigator.of(ctx).pop(false),
          ),
          SailButton(
            label: 'Switch',
            onPressed: () async => Navigator.of(ctx).pop(true),
          ),
        ],
        child: SailText.secondary13(
          'Bitcoin Core will be stopped, the new build downloaded if needed, and then restarted.',
        ),
      ),
    );
    if (confirmed != true) return;

    await _variantProvider.setVariant(id);
    if (!mounted) return;
    final err = _variantProvider.lastError;
    if (err != null) {
      showSailToast(
        context,
        'Failed to switch Core variant: $err',
        variant: SailToastVariant.destructive,
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
                SailDropdownItem<BitcoinNetwork>(
                  value: BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
                  label: BitcoinNetwork.BITCOIN_NETWORK_REGTEST.toDisplayName(),
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
              SailText.primary15(
                _confProvider.network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET
                    ? 'Bitcoin Data Directory — Forknet'
                    : 'Bitcoin Data Directory — Default',
              ),
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

/// Pushes the full-page network swap flow. The shared Sail UI datadir
/// precondition runs first; only a configured target network reaches
/// [NetworkSwapPage], which performs the stop/save/boot progress flow.
Future<void> swapNetworkWithDatadirPrompt(
  BuildContext context,
  BitcoinConfProvider provider,
  BitcoinNetwork network,
) async {
  if (provider.network == network) return;

  final ready = await provider.ensureDataDirForNetwork(context, network);
  if (!ready) return;

  if (!context.mounted) return;
  await Navigator.of(context).push<bool>(
    sailRoute(
      builder: (_) => NetworkSwapPage(
        fromNetwork: provider.network,
        toNetwork: network,
      ),
    ),
  );
}
