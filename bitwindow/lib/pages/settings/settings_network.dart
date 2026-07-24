import 'package:bitwindow/pages/settings/network_swap_page.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
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
  ElectrumServerProvider get _electrumProvider => GetIt.I.get<ElectrumServerProvider>();
  TorConfigProvider get _torProvider => GetIt.I.get<TorConfigProvider>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();
  BinaryProvider get _binaryProvider => GetIt.I.get<BinaryProvider>();
  Logger get _log => GetIt.I.get<Logger>();
  bool _isSelectingDataDir = false;
  bool _isPickingSnapshot = false;
  final _electrumServerController = TextEditingController();
  final _torProxyController = TextEditingController();
  final _snapshotController = TextEditingController();
  GetSnapshotStatusResponse? _snapshotStatus;

  bool get _isElectrumWallet => _walletReader.activeWallet?.isElectrum ?? false;

  @override
  void initState() {
    super.initState();
    _settingsProvider.addListener(setstate);
    _confProvider.addListener(setstate);
    _variantProvider.addListener(setstate);
    _electrumProvider.addListener(_onElectrumChanged);
    _torProvider.addListener(_onTorChanged);
    _walletReader.addListener(setstate);
    // Pick up live edits to chains_config.json since the last refresh.
    _variantProvider.refresh();
    if (_isElectrumWallet) {
      _electrumProvider.refresh();
      _torProvider.refresh();
    }
    _loadSnapshotStatus();
  }

  Future<void> _loadSnapshotStatus() async {
    try {
      final status = await _binaryProvider.getSnapshotStatus();
      if (!mounted) return;
      setState(() {
        _snapshotStatus = status;
        // Pre-fill with the snapshot published for this network, unless the
        // user has already typed one.
        if (_snapshotController.text.isEmpty && status.availableUrl.isNotEmpty) {
          _snapshotController.text = status.availableUrl;
        }
      });
    } catch (e) {
      _log.w('could not load snapshot status: $e');
    }
  }

  String? _snapshotStatusText() {
    final status = _snapshotStatus;
    if (status == null) return null;
    if (status.hasActiveSnapshot) {
      if (status.activeValidated) {
        return 'Snapshot loaded and fully validated (block ${status.activeHeight}).';
      }
      final pct = (status.activeVerificationProgress * 100).toStringAsFixed(1);
      return 'Snapshot active at block ${status.activeHeight}, validating history in the background ($pct%).';
    }
    if (status.availableUrl.isNotEmpty) {
      return 'Published snapshot for this network: block ${status.availableHeight}. Load it to sync in minutes.';
    }
    return 'No snapshot is published for this network.';
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(setstate);
    _confProvider.removeListener(setstate);
    _variantProvider.removeListener(setstate);
    _electrumProvider.removeListener(_onElectrumChanged);
    _torProvider.removeListener(_onTorChanged);
    _walletReader.removeListener(setstate);
    _electrumServerController.dispose();
    _torProxyController.dispose();
    _snapshotController.dispose();
    super.dispose();
  }

  void _onElectrumChanged() {
    // Keep the field in sync with the backend's current endpoint unless the
    // user is mid-edit (controller already holds the live value).
    final current = _electrumProvider.url;
    if (current.isNotEmpty && _electrumServerController.text.isEmpty) {
      _electrumServerController.text = current;
    }
    setstate();
  }

  Future<void> _applyElectrumServer() async {
    final tip = await _electrumProvider.setServer(_electrumServerController.text.trim());
    if (!mounted) return;
    final err = _electrumProvider.lastError;
    if (err != null) {
      showSailToast(
        context,
        'Could not switch server (kept previous): $err',
        variant: SailToastVariant.destructive,
      );
      return;
    }
    showSailToast(
      context,
      'Connected to ${_electrumProvider.url} (tip height $tip)',
      variant: SailToastVariant.success,
    );
  }

  Future<void> _resetElectrumServer() async {
    final tip = await _electrumProvider.setServer('');
    if (!mounted) return;
    final err = _electrumProvider.lastError;
    if (err != null) {
      showSailToast(
        context,
        'Could not reset server (kept previous): $err',
        variant: SailToastVariant.destructive,
      );
      return;
    }
    _electrumServerController.text = _electrumProvider.url;
    showSailToast(
      context,
      'Reset to default server (tip height $tip)',
      variant: SailToastVariant.success,
    );
  }

  void _onTorChanged() {
    if (_torProxyController.text.isEmpty) {
      _torProxyController.text = _torProvider.proxy.isNotEmpty ? _torProvider.proxy : _torProvider.defaultProxy;
    }
    setstate();
  }

  Future<void> _applyTorConfig(bool enabled) async {
    final proxy = _torProxyController.text.trim();
    final tip = await _torProvider.apply(enabled, proxy);
    if (!mounted) return;
    final err = _torProvider.lastError;
    if (err != null) {
      showSailToast(
        context,
        'Could not apply Tor config (kept previous): $err',
        variant: SailToastVariant.destructive,
      );
      return;
    }
    showSailToast(
      context,
      enabled ? 'Routing through ${_torProvider.proxy} (tip height $tip)' : 'Tor routing disabled (tip height $tip)',
      variant: SailToastVariant.success,
    );
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

  Future<void> _pickSnapshotFile() async {
    setState(() => _isPickingSnapshot = true);
    try {
      final result = await FilePicker.pickFiles(dialogTitle: 'Choose a UTXO snapshot');
      final path = result?.files.single.path;
      if (path != null) {
        _snapshotController.text = path;
      }
    } catch (e) {
      if (mounted) {
        showSailToast(context, 'Could not open the file picker: $e', variant: SailToastVariant.destructive);
      }
    } finally {
      if (mounted) setState(() => _isPickingSnapshot = false);
    }
  }

  Future<void> _applySnapshot() async {
    final source = _snapshotController.text.trim();
    if (source.isEmpty) {
      showSailToast(context, 'Enter a snapshot URL or choose a file first', variant: SailToastVariant.destructive);
      return;
    }
    // A bare URL is downloaded; anything else is treated as a local file.
    final isURL = source.startsWith('http://') || source.startsWith('https://');

    final applied = await Navigator.of(context).push<bool>(
      sailRoute(
        builder: (_) => UTXOSnapshotPage(
          url: isURL ? source : '',
          filePath: isURL ? '' : source,
        ),
      ),
    );
    if (applied == true) {
      _snapshotController.clear();
    }
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
        _confProvider.network == BitcoinNetwork.BITCOIN_NETWORK_DRYNET ||
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
        if (_isElectrumWallet)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Electrum Server'),
              const SailSpacing(SailStyleValues.padding08),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: _electrumServerController,
                      hintText: _electrumProvider.defaultUrl.isEmpty ? 'https://...' : _electrumProvider.defaultUrl,
                      enabled: !_electrumProvider.busy,
                      maxLines: 1,
                      onSubmitted: (_) async => _applyElectrumServer(),
                    ),
                  ),
                  SailButton(
                    label: 'Apply / Test',
                    small: true,
                    loading: _electrumProvider.busy,
                    onPressed: () async => _applyElectrumServer(),
                  ),
                  if (_electrumProvider.isOverride)
                    SailButton(
                      label: 'Reset',
                      small: true,
                      variant: ButtonVariant.secondary,
                      onPressed: () async => _resetElectrumServer(),
                    ),
                ],
              ),
              const SailSpacing(4),
              SailText.secondary12(
                _electrumProvider.isOverride
                    ? 'Using a custom Esplora server. Reset to return to the network default.'
                    : 'Esplora API endpoint this electrum wallet reads from and broadcasts to',
              ),
            ],
          ),
        if (_isElectrumWallet)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Tor Routing'),
              const SailSpacing(SailStyleValues.padding08),
              SailToggle(
                label: 'Route through Tor',
                value: _torProvider.enabled,
                onChanged: (v) async => _applyTorConfig(v),
              ),
              const SailSpacing(SailStyleValues.padding08),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: _torProxyController,
                      hintText: _torProvider.defaultProxy.isEmpty ? '127.0.0.1:9050' : _torProvider.defaultProxy,
                      enabled: !_torProvider.busy,
                      maxLines: 1,
                      onSubmitted: (_) async => _applyTorConfig(true),
                    ),
                  ),
                  SailButton(
                    label: 'Apply / Test',
                    small: true,
                    loading: _torProvider.busy,
                    onPressed: () async => _applyTorConfig(true),
                  ),
                ],
              ),
              const SailSpacing(4),
              SailText.secondary12(
                'SOCKS5 proxy (system Tor 127.0.0.1:9050 or Tor Browser 127.0.0.1:9150) '
                'used to hide your IP from the Esplora server and reach .onion endpoints',
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
                  value: BitcoinNetwork.BITCOIN_NETWORK_DRYNET,
                  label: BitcoinNetwork.BITCOIN_NETWORK_DRYNET.toDisplayName(),
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
                switch (_confProvider.network) {
                  BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 'Bitcoin Data Directory — Forknet',
                  BitcoinNetwork.BITCOIN_NETWORK_DRYNET => 'Bitcoin Data Directory — Drynet',
                  _ => 'Bitcoin Data Directory — Default',
                },
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('UTXO Snapshot'),
            const SailSpacing(SailStyleValues.padding08),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailTextField(
                    controller: _snapshotController,
                    hintText: 'https://example.com/utxo-957600.dat',
                  ),
                ),
                SailButton(
                  label: 'Choose file',
                  small: true,
                  variant: ButtonVariant.secondary,
                  loading: _isPickingSnapshot,
                  onPressed: () async => await _pickSnapshotFile(),
                ),
                SailButton(
                  label: 'Load',
                  small: true,
                  onPressed: () async => await _applySnapshot(),
                ),
              ],
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'Skip the historical download by loading an assumeutxo snapshot, so Bitcoin Core validates at the tip within minutes and backfills history afterwards. Nothing is deleted, and your own bitcoin.conf is not touched.',
            ),
            if (_snapshotStatusText() != null) ...[
              const SailSpacing(SailStyleValues.padding08),
              SailText.secondary12(_snapshotStatusText()!),
            ],
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
