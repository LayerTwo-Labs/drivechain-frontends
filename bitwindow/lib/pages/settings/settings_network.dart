import 'package:bitwindow/pages/settings/network_swap_page.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/widgets/ecash_upgrade_banner.dart';
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
      if (!mounted) {
        return;
      }
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
    if (status == null) {
      return null;
    }
    if (status.hasActiveSnapshot) {
      if (status.activeValidated) {
        return 'Snapshot loaded and fully validated (block ${status.activeHeight}).';
      }
      final pct = (status.activeVerificationProgress * 100).toStringAsFixed(1);
      return 'Snapshot active at block ${status.activeHeight}, validating history in the background ($pct%).';
    }
    if (status.availableUrl.isNotEmpty) {
      return 'Published snapshot for this network: block ${status.availableHeight}.';
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
    if (!mounted) {
      return;
    }
    final err = _electrumProvider.lastError;
    if (err != null) {
      showSailToast(
        context,
        'Could not switch server: $err',
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
    if (!mounted) {
      return;
    }
    final err = _electrumProvider.lastError;
    if (err != null) {
      showSailToast(
        context,
        'Could not reset server: $err',
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
    if (!mounted) {
      return;
    }
    final err = _torProvider.lastError;
    if (err != null) {
      showSailToast(
        context,
        'Could not apply Tor config: $err',
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

  Future<void> _handleNetworkChange(NetworkOption? option) async {
    if (option == null) {
      return;
    }

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

    await swapNetworkWithDatadirPrompt(
      context,
      _confProvider,
      _confProvider.networkFromOption(option),
      networkId: option.id,
    );
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
        if (!mounted) {
          return;
        }
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
      final result = await FilePicker.pickFile(dialogTitle: 'Choose a UTXO snapshot');
      final path = result?.path;
      if (path != null) {
        _snapshotController.text = path;
      }
    } catch (e) {
      if (mounted) {
        showSailToast(
          context,
          'Could not open the file picker: $e',
          variant: SailToastVariant.destructive,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingSnapshot = false);
      }
    }
  }

  Future<void> _applySnapshot() async {
    final source = _snapshotController.text.trim();
    if (source.isEmpty) {
      showSailToast(
        context,
        'Enter a snapshot URL or choose a file first',
        variant: SailToastVariant.destructive,
      );
      return;
    }
    // A bare URL is downloaded; anything else is treated as a local file.
    final isURL = source.startsWith('http://') || source.startsWith('https://');

    final applied = await Navigator.of(context).push<bool>(
      sailRoute(
        builder: (_) => UTXOSnapshotPage(url: isURL ? source : '', filePath: isURL ? '' : source),
      ),
    );
    if (applied == true) {
      _snapshotController.clear();
    }
  }

  Future<void> _handleVariantChange(String? id) async {
    if (id == null || id == _variantProvider.activeId) {
      return;
    }

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
          SailButton(label: 'Switch', onPressed: () async => Navigator.of(ctx).pop(true)),
        ],
        child: SailText.secondary13(
          'Bitcoin Core will be stopped, the new build downloaded if needed, and then restarted.',
        ),
      ),
    );
    if (confirmed != true) {
      return;
    }

    await _variantProvider.setVariant(id);
    if (!mounted) {
      return;
    }
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
        _confProvider.network == BitcoinNetwork.BITCOIN_NETWORK_ECASH ||
        _confProvider.detectedDataDir != null;
    final canEditDataDir = !_confProvider.hasPrivateBitcoinConf;

    return SailSettingsBody(
      children: [
        SailSettingsGroup(
          title: 'Bitcoin network',
          children: [
            SailSettingsRow(
              label: 'Network',
              description: _confProvider.hasPrivateBitcoinConf
                  ? 'Your own bitcoin.conf file controls the network'
                  : 'The network this node connects to',
              trailing: SailDropdownButton<String>(
                value: _confProvider.currentNetworkOptionId,
                enabled: !_confProvider.hasPrivateBitcoinConf,
                items: _confProvider.networkOptions
                    .map((o) => SailDropdownItem<String>(value: o.id, label: o.displayName))
                    .toList(),
                onChanged: (String? id) async {
                  if (id != null && !_confProvider.hasPrivateBitcoinConf) {
                    await _handleNetworkChange(_confProvider.optionById(id));
                  }
                },
              ),
            ),
            if (showDataDir)
              SailSettingsRow(
                label: 'Data directory',
                description: canEditDataDir
                    ? 'Where Bitcoin Core writes chain data (2.5TB+ on mainnet)'
                    : 'Your own bitcoin.conf file controls the data directory',
                trailing: canEditDataDir
                    ? SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailButton(
                            label: 'Browse',
                            small: true,
                            variant: ButtonVariant.secondary,
                            loading: _isSelectingDataDir,
                            onPressed: () async => await _selectDataDirectory(),
                          ),
                          if (_confProvider.detectedDataDir != null)
                            SailButton(
                              label: 'Clear',
                              small: true,
                              variant: ButtonVariant.ghost,
                              onPressed: () async => await _clearDataDir(),
                            ),
                        ],
                      )
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding08,
                    vertical: SailStyleValues.padding04,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colors.border),
                    borderRadius: theme.chrome.radiusSmall,
                    color: theme.colors.backgroundSecondary,
                  ),
                  child: SailText.secondary12(_confProvider.detectedDataDir ?? 'Default directory'),
                ),
              ),
            SailSettingsRow(
              label: 'bitcoin.conf',
              description: 'Edit the Bitcoin Core configuration file',
              trailing: SailButton(
                label: 'Edit',
                small: true,
                variant: ButtonVariant.secondary,
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  final router = GetIt.I.get<AppRouter>();
                  await router.push(BitcoinConfEditorRoute());
                },
              ),
            ),
          ],
        ),
        SailSettingsGroup(
          title: 'Bitcoin Core',
          children: [
            if (_variantProvider.isVisible)
              SailSettingsRow(
                label: 'Build',
                description: 'Which Bitcoin Core build the orchestrator runs',
                trailing: SailDropdownButton<String>(
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
              ),
            SailSettingsRow(
              label: 'UTXO snapshot',
              description: _snapshotStatusText() ?? 'Load an assumeutxo snapshot to skip the historical download',
              child: SailRow(
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
            ),
          ],
        ),
        if (_isElectrumWallet)
          SailSettingsGroup(
            title: 'Connection',
            children: [
              SailSettingsRow(
                label: 'Esplora server',
                description: _electrumProvider.isOverride
                    ? 'Custom server. Reset to return to the network default.'
                    : 'The endpoint this wallet reads from and broadcasts to',
                child: SailRow(
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
                      label: 'Apply',
                      small: true,
                      loading: _electrumProvider.busy,
                      onPressed: () async => _applyElectrumServer(),
                    ),
                    if (_electrumProvider.isOverride)
                      SailButton(
                        label: 'Reset',
                        small: true,
                        variant: ButtonVariant.ghost,
                        onPressed: () async => _resetElectrumServer(),
                      ),
                  ],
                ),
              ),
              SailSettingsRow(
                label: 'Tor routing',
                description: 'Hides your IP from the Esplora server and reaches .onion endpoints',
                trailing: SailToggle(
                  value: _torProvider.enabled,
                  onChanged: (v) async => _applyTorConfig(v),
                ),
                child: SailRow(
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
                      label: 'Apply',
                      small: true,
                      loading: _torProvider.busy,
                      onPressed: () async => _applyTorConfig(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Pushes the full-page network swap flow. The backend reports what the user
/// must resolve first; only a resolved change reaches [NetworkSwapPage].
Future<void> swapNetworkWithDatadirPrompt(
  BuildContext context,
  BitcoinConfProvider provider,
  BitcoinNetwork network, {
  String networkId = '',
}) async {
  // An eCash id change keeps the slot, so compare the id too or a switch from
  // one eCash fork to another reads as a no-op.
  if (provider.network == network && (networkId.isEmpty || networkId == provider.ecashNetworkId)) {
    return;
  }

  final plan = await provider.prepareNetworkChange(targetNetwork: network, networkId: networkId);
  if (plan.noOp) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final dataDir = await provider.resolveNetworkChangePlan(context, plan, network);
  if (dataDir == null) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  var targetId = networkId;
  if (network == BitcoinNetwork.BITCOIN_NETWORK_ECASH) {
    final outcome = await confirmPendingECashUpgrade(context);
    if (outcome == ECashUpgradeOutcome.cancelled) {
      return;
    }
    // An applied upgrade is the switch itself only when eCash already ran.
    // From another network it records the generation and leaves the active
    // network alone, so the move below still has to happen — on the generation
    // the user just confirmed, not the row they started from.
    if (outcome == ECashUpgradeOutcome.applied) {
      if (provider.network == BitcoinNetwork.BITCOIN_NETWORK_ECASH) {
        return;
      }
      if (provider.ecashNetworkId.isNotEmpty) {
        targetId = provider.ecashNetworkId;
      }
    }
    if (!context.mounted) {
      return;
    }
    // The pending prompt only fires for a published upgrade. A pick made from
    // the dropdown moves the chain just as much, so it asks too.
    if (!await confirmECashSwitch(context, targetId)) {
      return;
    }
  }

  if (!context.mounted) {
    return;
  }
  await Navigator.of(context).push<bool>(
    sailRoute(
      builder: (_) => NetworkSwapPage(
        fromNetwork: provider.network,
        toNetwork: network,
        dataDir: dataDir,
        networkId: targetId,
      ),
    ),
  );
}
