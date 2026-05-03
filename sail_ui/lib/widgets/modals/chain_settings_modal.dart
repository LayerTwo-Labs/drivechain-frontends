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
  bool _loadingVersion = true;

  @override
  void initState() {
    super.initState();
    _loadArgs();
    _loadBinaryVersion();
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
      final settingsProvider = GetIt.I.get<SettingsProvider>();

      // Skip version check for test sidechains (Flutter apps don't support --version)
      if (settingsProvider.useTestSidechains && widget.connection.binary.chainLayer == 2) {
        if (mounted) {
          setState(() {
            _binaryVersion = 'Test Sidechain';
            _loadingVersion = false;
          });
        }
        return;
      }

      final version = await widget.connection.binary.binaryVersion(
        binaryProvider.appDir,
      );

      if (mounted) {
        setState(() {
          _binaryVersion = version;
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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChainSettingsViewModel>.reactive(
      viewModelBuilder: () => ChainSettingsViewModel(widget.connection.binary),
      builder: (context, viewModel, child) {
        final theme = SailTheme.of(context);

        final baseDir = viewModel.binary.directories.binary[GetIt.I.get<BitcoinConfProvider>().network]?[viewModel.os];
        final downloadFile =
            viewModel.binary.metadata.downloadConfig.files[GetIt.I.get<BitcoinConfProvider>().network]![viewModel.os];

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            height: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadius,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SailText.primary20('${viewModel.binary.name} Settings'),
                      // Update button - only show if update is available and not currently updating
                      if (viewModel.showUpdateButton)
                        SailButton(
                          label: 'Update',
                          onPressed: viewModel.isUpdating ? null : () => viewModel.handleUpdate(context),
                          loading: viewModel.isUpdating,
                          loadingLabel: 'Updating',
                        ),
                      SailButton(
                        onPressed: () async {
                          final binaryProvider = GetIt.I.get<BinaryProvider>();
                          final appDir = GetIt.I.get<BinaryProvider>().appDir;
                          final binary = widget.connection.binary;

                          await binaryProvider.stop(
                            binary,
                            skipDownstream: true,
                          );

                          // Delete binaries and all datadir paths
                          await binary.deleteBinaries(binDir(appDir.path));
                          final allPaths = await binary.getAllDatadirPaths();
                          await binary.deleteFiles(allPaths);
                          await copyBinariesFromAssets(
                            GetIt.I.get<Logger>(),
                            appDir,
                          );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        variant: ButtonVariant.icon,
                        icon: SailSVGAsset.trash,
                        textColor: SailColorScheme.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  StaticField(
                    label: 'Version',
                    value: _loadingVersion ? 'Loading...' : (_binaryVersion ?? viewModel.binary.version),
                    copyable: true,
                  ),
                  if (viewModel.binary.repoUrl.isNotEmpty)
                    StaticField(
                      label: 'Repository',
                      value: viewModel.binary.repoUrl,
                      copyable: true,
                    ),
                  StaticField(
                    label: 'Host',
                    value: '127.0.0.1',
                    copyable: true,
                  ),
                  StaticField(
                    label: 'Port',
                    value: widget.connection.binary.port != 0
                        ? widget.connection.binary.port.toString()
                        : CoreConnectionSettings.empty(
                            GetIt.I.get<BitcoinConfProvider>().network,
                          ).port.toString(),
                    copyable: true,
                  ),
                  if (args.isNotEmpty)
                    StaticField(
                      label: 'Binary Arguments',
                      value: args.join(' \\\n'),
                      copyable: true,
                    ),
                  StaticField(
                    label: 'Chain Layer',
                    value: viewModel.binary.chainLayer == 0
                        ? 'Utility'
                        : viewModel.binary.chainLayer == 1
                        ? 'Layer 1'
                        : 'Layer 2',
                    copyable: true,
                  ),
                  if (baseDir != null)
                    StaticField(
                      label: 'Installation Directory',
                      value: baseDir,
                      copyable: true,
                    ),
                  StaticField(
                    label: 'Binary Data Directory',
                    value: viewModel.binary.datadirNetwork(),
                    copyable: true,
                  ),
                  StaticField(
                    label: 'Log Path',
                    value: viewModel.binary.logPath(),
                    copyable: true,
                  ),
                  StaticField(
                    label: 'Binary Asset Path',
                    value: viewModel.binary.metadata.binaryPath?.path ?? 'N/A',
                    copyable: true,
                  ),
                  if (downloadFile != null)
                    viewModel.buildInfoRow(
                      context,
                      'Download File',
                      downloadFile,
                    ),
                  _HashVerificationSection(
                    downloadInfo: viewModel.binary.downloadInfo,
                  ),
                  StaticField(
                    label: 'Latest Release At',
                    value: viewModel.binary.metadata.remoteTimestamp?.toLocal().toString() ?? 'N/A',
                    copyable: true,
                  ),
                  StaticField(
                    label: 'Your Version Installed At',
                    value: viewModel.binary.metadata.downloadedTimestamp?.toLocal().toString() ?? 'N/A',
                    copyable: true,
                  ),
                  const SizedBox(height: 24),
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onOpenConfConfigurator != null)
                        SailButton(
                          label: 'Open Conf Configurator',
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        padding: const EdgeInsets.only(bottom: 8),
        child: SailText.secondary12(
          'No hash data available (re-download to verify)',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SailText.primary13(
          'Hash Verification',
          color: theme.colors.textTertiary,
        ),
        const SizedBox(height: 8),
        if (localHash != null) _HashRow(label: 'Local SHA256', hash: localHash),
        if (releaseHash != null)
          _HashRow(
            label: 'Release Server',
            hash: releaseHash,
            isMismatch: localHash != null && releaseHash != localHash,
          ),
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
          ),
        const SizedBox(height: 8),
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
        padding: const EdgeInsets.only(bottom: 4),
        decoration: isMismatch ? BoxDecoration(color: theme.colors.error.withValues(alpha: 0.1)) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: SailText.secondary12(
                label,
                color: isMismatch ? theme.colors.error : null,
              ),
            ),
            Expanded(
              child: SelectableText(
                '${hash.substring(0, 16)}...${hash.substring(hash.length - 16)}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
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
  bool get showUpdateButton => _binary.updateAvailable && !_isUpdating;

  Future<void> handleUpdate(BuildContext context) async {
    if (_isUpdating) return;

    _isUpdating = true;
    notifyListeners();

    try {
      // 1. Download the updated binary
      Navigator.of(context).pop();
      await _binaryProvider.download(_binary, shouldUpdate: true);

      bool wasRunning = _binaryProvider.isConnected(_binary);
      if (wasRunning) {
        // 2. Restart the binary with retry logic (3 attempts, 5 second wait).
        // Per-daemon scope: restarting one binary here must not poke its
        // siblings.
        bool started = false;
        int attempts = 0;
        const maxAttempts = 3;
        const retryDelay = Duration(seconds: 5);

        while (!started && attempts < maxAttempts) {
          attempts++;
          try {
            await _binaryProvider.restart(_binary);
            started = true;
          } catch (e) {
            if (attempts < maxAttempts) {
              await Future.delayed(retryDelay);
            } else {
              rethrow;
            }
          }
        }
      }
    } catch (e) {
      // Handle any errors during the update process
      // You might want to show a snackbar or dialog here
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> handleDelete() async {
    await _binary.deleteBinaries(binDir(appDir.path));
    final allPaths = await _binary.getAllDatadirPaths();
    await _binary.deleteFiles(allPaths);
  }

  Widget buildInfoRow(BuildContext context, String label, String value) {
    final theme = SailTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13(label, color: theme.colors.textTertiary),
          const SizedBox(height: 4),
          SailText.primary13(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
