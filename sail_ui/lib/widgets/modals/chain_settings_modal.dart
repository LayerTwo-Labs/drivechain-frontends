import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ChainSettingsModal extends StatefulWidget {
  final RPCConnection connection;
  final VoidCallback? onOpenConfConfigurator;

  const ChainSettingsModal({
    super.key,
    required this.connection,
    this.onOpenConfConfigurator,
  });

  @override
  State<ChainSettingsModal> createState() => _ChainSettingsModalState();
}

class _ChainSettingsModalState extends State<ChainSettingsModal> {
  List<String> args = [];
  String? _binaryVersion;
  String? _resolvedBinaryPath;
  bool _loadingVersion = true;

  final TextEditingController _rollbackHeight = TextEditingController();
  int? _chainHeight;
  bool _rollingBack = false;
  String? _rollbackError;
  String? _rollbackResult;

  @override
  void initState() {
    super.initState();
    _loadArgs();
    _loadBinaryVersion();
    _loadChainHeight();
  }

  @override
  void dispose() {
    _rollbackHeight.dispose();
    super.dispose();
  }

  Future<void> _loadArgs() async {
    final loadedArgs = await widget.connection.binaryArgs();
    // Create a mutable copy since extraBootArgs may be const
    final mutableArgs = List<String>.from(loadedArgs);
    mutableArgs.removeWhere((arg) => arg.contains('pass'));
    if (mounted) {
      setState(() {
        args = mutableArgs;
      });
    }
  }

  Future<void> _loadBinaryVersion() async {
    setState(() {
      _loadingVersion = true;
    });

    try {
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      final binary = widget.connection.binary;

      // The orchestrator owns path resolution and runs --version; the frontend
      // never guesses. Sidechains (L2) pass forceBackend so we read the real
      // Rust node version, not the Flutter test build (which has no --version).
      final name = binaryProvider.orchestratorName(binary);
      if (name != null) {
        final resp = await GetIt.I.get<OrchestratorRPC>().getBinaryVersion(
          name,
          forceBackend: binary.chainLayer == 2,
        );
        if (mounted) {
          setState(() {
            _binaryVersion = resp.isTestBuild ? 'Test Sidechain' : resp.version;
            _resolvedBinaryPath = resp.binaryPath.isEmpty ? null : resp.binaryPath;
            _loadingVersion = false;
          });
        }
        return;
      }

      // Daemons without an orchestrator name (none today) fall back to the
      // configured version string.
      if (mounted) {
        setState(() {
          _binaryVersion = binary.version;
          _loadingVersion = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _binaryVersion = 'Error: $e';
          _loadingVersion = false;
        });
      }
    }
  }

  /// The rollback acts on Bitcoin Core's chain, so only Core's own settings
  /// offer it. The enforcer and bitwindowd are layer 1 too, and their modal
  /// must not roll back a chain they do not own.
  bool get _isBitcoinCore => widget.connection.binary.type == BinaryType.BINARY_TYPE_BITCOIND;

  Future<void> _loadChainHeight() async {
    if (!_isBitcoinCore) {
      return;
    }
    try {
      final info = await widget.connection.getBlockchainInfo();
      if (mounted) {
        setState(() => _chainHeight = info.blocks);
      }
    } catch (e) {
      // The tab reads the height as a hint, so a daemon that is still coming
      // up leaves it blank rather than blocking the modal.
      GetIt.I.get<Logger>().d('chain settings: could not read the height: $e');
    }
  }

  Future<void> _rollBack(BuildContext context) async {
    final height = int.tryParse(_rollbackHeight.text.trim());
    if (height == null) {
      setState(() => _rollbackError = 'Type the block height to keep.');
      return;
    }

    // The rollback drops the active branch and can delete the enforcer's
    // validator chain, and the modal cannot undo either.
    await infoDialog(
      context: context,
      title: 'Roll back to block $height?',
      subtitle:
          'Every block above $height leaves the active chain. '
          'The enforcer rebuilds from the local Core if it does not follow.',
      onConfirm: () async {
        Navigator.of(context).pop();
        await _sendRollback(height);
      },
    );
  }

  Future<void> _sendRollback(int height) async {
    setState(() {
      _rollingBack = true;
      _rollbackError = null;
      _rollbackResult = null;
    });

    try {
      final resp = await GetIt.I.get<OrchestratorRPC>().wipeUntilBlock(height);
      if (!mounted) {
        return;
      }
      setState(() {
        _chainHeight = resp.coreHeight;
        _rollbackResult = resp.enforcerRebuilt
            ? 'Core is at ${resp.coreHeight}. The enforcer rebuilds from the local Core.'
            : 'Core is at ${resp.coreHeight}. The enforcer followed at ${resp.enforcerHeight}.';
      });
    } catch (e) {
      if (mounted) {
        setState(() => _rollbackError = '$e');
      }
    } finally {
      if (mounted) {
        setState(() => _rollingBack = false);
      }
    }
  }

  Future<void> _showWipeReset(BuildContext context, Binary binary) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final appDir = binaryProvider.appDir;
    final log = GetIt.I.get<Logger>();

    // Wipe everything for this one binary. Wallet included for enforcer and
    // sidechains (moved to wallet_backups/ server-side); excluded for bitcoind
    // and bitwindow, whose L1 wallet is only ever wiped from the reset page.
    final deletions = <DeletionType>[
      DeletionType.DELETION_TYPE_DATA,
      DeletionType.DELETION_TYPE_SETTINGS,
      DeletionType.DELETION_TYPE_LOGS,
      DeletionType.DELETION_TYPE_SOFTWARE,
      if (binary.type != BinaryType.BINARY_TYPE_BITCOIND && binary.type != BinaryType.BINARY_TYPE_BITWINDOWD)
        DeletionType.DELETION_TYPE_WALLET,
    ];

    final resetStarted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResetConfirmationPage(
          request: [SingleDeletion(binary: binary.type, deletions: deletions)],
          appDir: appDir,
          binaryProvider: binaryProvider,
          log: log,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (resetStarted == true) {
      Navigator.of(context).pop();
    }
  }

  String _port() {
    if (widget.connection.binary.port != 0) {
      return widget.connection.binary.port.toString();
    }
    return CoreConnectionSettings.empty(
      GetIt.I.get<BitcoinConfProvider>().network,
    ).port.toString();
  }

  String _chainLayer(Binary binary) {
    switch (binary.chainLayer) {
      case 0:
        return 'Utility';
      case 1:
        return 'Layer 1';
      default:
        return 'Layer 2';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChainSettingsViewModel>.reactive(
      viewModelBuilder: () => ChainSettingsViewModel(widget.connection.binary),
      builder: (context, viewModel, child) {
        final theme = SailTheme.of(context);
        final binary = viewModel.binary;
        final version = _loadingVersion ? 'Loading...' : (_binaryVersion ?? binary.version);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 640,
            height: 620,
            padding: const EdgeInsets.all(SailStyleValues.padding25),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadius,
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, viewModel, version),
                Expanded(
                  child: InlineTabBar(
                    tabs: [
                      SingleTabItem(label: 'Overview', child: _overviewTab(viewModel, version)),
                      SingleTabItem(label: 'Paths', child: _pathsTab(viewModel)),
                      if (_isBitcoinCore) SingleTabItem(label: 'Chain', child: _chainTab(context, theme)),
                    ],
                  ),
                ),
                _footer(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, ChainSettingsViewModel viewModel, String version) {
    final theme = SailTheme.of(context);
    final binary = viewModel.binary;

    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        Expanded(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary20(binary.name),
              SailText.secondary13(
                '${_chainLayer(binary)} · 127.0.0.1:${_port()} · version $version',
                color: theme.colors.textSecondary,
              ),
            ],
          ),
        ),
        if (viewModel.showUpdateButton)
          SailButton(
            label: 'Update',
            onPressed: viewModel.isUpdating ? null : () => viewModel.handleUpdate(context),
            loading: viewModel.isUpdating,
            loadingLabel: 'Updating',
          ),
      ],
    );
  }

  Widget _overviewTab(ChainSettingsViewModel viewModel, String version) {
    final binary = viewModel.binary;
    final network = GetIt.I.get<BitcoinConfProvider>().network;
    var downloadFile = binary.metadata.downloadConfig.files[network]?[viewModel.os];
    final variants = binary.metadata.downloadConfig.variants;
    if (downloadFile == null && variants.isNotEmpty && GetIt.I.isRegistered<CoreVariantProvider>()) {
      final activeId = GetIt.I.get<CoreVariantProvider>().activeId;
      downloadFile = (variants[activeId] ?? variants.values.first)[viewModel.os];
    }

    return SingleChildScrollView(
      child: SailColumn(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldRow(label: 'Version', value: version),
          if (binary.repoUrl.isNotEmpty) _FieldRow(label: 'Repository', value: binary.repoUrl, copyable: true),
          _FieldRow(
            label: 'Latest release at',
            value: binary.metadata.remoteTimestamp?.toLocal().toString() ?? 'N/A',
          ),
          _FieldRow(
            label: 'Installed at',
            value: binary.metadata.downloadedTimestamp?.toLocal().toString() ?? 'N/A',
          ),
          if (downloadFile != null) _FieldRow(label: 'Download file', value: downloadFile, copyable: true),
          _HashVerificationSection(downloadInfo: binary.downloadInfo),
        ],
      ),
    );
  }

  Widget _pathsTab(ChainSettingsViewModel viewModel) {
    final binary = viewModel.binary;
    final network = GetIt.I.get<BitcoinConfProvider>().network;
    final baseDir = binary.directories.binary[network]?[viewModel.os];

    return SingleChildScrollView(
      child: SailColumn(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (baseDir != null) _FieldRow(label: 'Installation directory', value: baseDir, copyable: true),
          _FieldRow(label: 'Data directory', value: binary.datadirNetwork(), copyable: true),
          _FieldRow(label: 'Log path', value: binary.logPath(), copyable: true),
          _FieldRow(
            label: 'Binary asset path',
            // Prefer the path the orchestrator actually resolved (and ran
            // --version against); fall back to the reported status path while
            // that's still loading.
            value: _resolvedBinaryPath ?? binary.metadata.binaryPath?.path ?? 'N/A',
            copyable: true,
          ),
          if (args.isNotEmpty) _FieldRow(label: 'Binary arguments', value: args.join(' \\\n'), copyable: true),
        ],
      ),
    );
  }

  Widget _chainTab(BuildContext context, SailThemeData theme) {
    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailColumn(
            spacing: 0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldRow(label: 'Network', value: GetIt.I.get<BitcoinConfProvider>().network.name),
              _FieldRow(label: 'Height', value: _chainHeight?.toString() ?? 'Loading...'),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            decoration: BoxDecoration(
              borderRadius: SailStyleValues.borderRadius,
              border: Border.all(color: theme.colors.border),
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13('Roll back the chain', bold: true),
                SailText.secondary13(
                  'Every block above the height leaves the active chain. Blocks below it stay on disk, so nothing downloads again.',
                  color: theme.colors.textSecondary,
                ),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Expanded(
                      child: SailTextField(
                        controller: _rollbackHeight,
                        hintText: 'Block height to keep',
                        textFieldType: TextFieldType.number,
                        dense: true,
                      ),
                    ),
                    SailButton(
                      label: 'Roll back',
                      onPressed: _rollingBack ? null : () async => _rollBack(context),
                      loading: _rollingBack,
                      loadingLabel: 'Rolling back',
                    ),
                  ],
                ),
                if (_rollbackError != null)
                  SailText.secondary12(_rollbackError!, color: theme.colors.error)
                else if (_rollbackResult != null)
                  SailText.secondary12(_rollbackResult!, color: theme.colors.success)
                else
                  SailText.secondary12(
                    'The enforcer follows the rollback. If it does not, it deletes its validator chain and rebuilds from the local Core.',
                    color: theme.colors.textTertiary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, ChainSettingsViewModel viewModel) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        Tooltip(
          message: 'Wipe ${viewModel.binary.name} binary, data, and wallets, then reinstall',
          child: SailButton(
            label: 'Wipe and reinstall',
            variant: ButtonVariant.ghost,
            textColor: SailColorScheme.red,
            onPressed: () async => _showWipeReset(context, viewModel.binary),
          ),
        ),
        const Spacer(),
        if (widget.onOpenConfConfigurator != null)
          SailButton(
            label: 'Open conf configurator',
            variant: ButtonVariant.outline,
            onPressed: () async {
              Navigator.pop(context);
              widget.onOpenConfConfigurator!();
            },
          ),
        SailButton(
          label: 'Close',
          onPressed: () async => Navigator.pop(context),
        ),
      ],
    );
  }
}

/// Label and value on one line, with an optional copy action.
class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _FieldRow({required this.label, required this.value, this.copyable = false});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.divider)),
      ),
      child: SailRow(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: SailText.secondary13(label, color: theme.colors.textTertiary),
          ),
          Expanded(child: SelectableText(value, style: SailStyleValues.thirteen)),
          if (copyable) CopyButton(text: value),
        ],
      ),
    );
  }
}

class _HashVerificationSection extends StatelessWidget {
  final DownloadInfo downloadInfo;

  const _HashVerificationSection({required this.downloadInfo});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final localHash = downloadInfo.hash;
    final releaseHash = downloadInfo.expectedHash;
    final isMismatch = downloadInfo.hashMatch == false;

    if (localHash == null && releaseHash == null) {
      return Padding(
        padding: const EdgeInsets.only(top: SailStyleValues.padding16),
        child: SailText.secondary12(
          'No hash data available (re-download to verify)',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SailStyleValues.padding20),
        SailText.secondary12('HASH VERIFICATION', color: theme.colors.textTertiary),
        const SizedBox(height: SailStyleValues.padding04),
        if (localHash != null) _HashRow(label: 'Local SHA256', hash: localHash),
        if (releaseHash != null)
          _HashRow(
            label: 'Release server',
            hash: releaseHash,
            isMismatch: localHash != null && releaseHash != localHash,
          ),
        const SizedBox(height: SailStyleValues.padding08),
        if (isMismatch)
          Tooltip(
            message:
                'The downloaded binary does not match the expected hash from the release server. '
                'This could indicate the binary was tampered with or the download was corrupted.',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.colors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  SailText.secondary12(
                    'HASH MISMATCH — binary may be compromised',
                    color: theme.colors.error,
                  ),
                ],
              ),
            ),
          )
        else if (downloadInfo.hashMatch == true)
          SailText.secondary12('Hashes match the release server.', color: theme.colors.success)
        else
          SailText.secondary12(
            'Not compared — one of the two hashes is missing.',
            color: theme.colors.textTertiary,
          ),
      ],
    );
  }
}

class _HashRow extends StatelessWidget {
  final String label;
  final String hash;
  final bool isMismatch;

  const _HashRow({
    required this.label,
    required this.hash,
    this.isMismatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Tooltip(
      message: hash,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 170,
              child: SailText.secondary13(
                label,
                color: isMismatch ? theme.colors.error : theme.colors.textTertiary,
              ),
            ),
            const SizedBox(width: SailStyleValues.padding16),
            Expanded(
              child: SelectableText(
                '${hash.substring(0, 16)}...${hash.substring(hash.length - 16)}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: isMismatch ? theme.colors.error : theme.colors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChainSettingsViewModel extends BaseViewModel {
  final BinaryProvider _binaryProvider = GetIt.I.get<BinaryProvider>();
  final Binary _binary;
  bool _isUpdating = false;

  ChainSettingsViewModel(this._binary) {
    _binaryProvider.addListener(notifyListeners);
  }

  Binary get binary => _binaryProvider.binaries.firstWhere((b) => b.type == _binary.type);
  bool get isUpdating => _isUpdating;
  Directory get appDir => _binaryProvider.appDir;
  OS get os => getOS();

  // Show update button only if update is available and not currently updating
  bool get showUpdateButton => binary.updateAvailable && !_isUpdating;

  Future<void> handleUpdate(BuildContext context) async {
    if (_isUpdating) {
      return;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      Navigator.of(context).pop();
      await _binaryProvider.update(binary);
    } catch (e) {
      // Handle any errors during the update process
      // You might want to show a snackbar or dialog here
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
