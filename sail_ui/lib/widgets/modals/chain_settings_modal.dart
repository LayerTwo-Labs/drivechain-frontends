import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/sidechain_main.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ChainSettingsModal extends StatefulWidget {
  final RPCConnection connection;

  const ChainSettingsModal({super.key, required this.connection});

  @override
  State<ChainSettingsModal> createState() => _ChainSettingsModalState();
}

class _ChainSettingsModalState extends State<ChainSettingsModal> {
  List<String> args = [];
  String deleteMessage = '';

  @override
  void initState() {
    super.initState();
    _loadArgs();
    setState(() {
      deleteMessage = 'Delete ${widget.connection.binary.name} data';
    });
  }

  Future<void> _loadArgs() async {
    final loadedArgs = await widget.connection.binaryArgs(widget.connection.conf);
    loadedArgs.removeWhere((arg) => arg.contains('pass'));
    if (mounted) {
      setState(() {
        args = loadedArgs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChainSettingsViewModel>.reactive(
      viewModelBuilder: () => ChainSettingsViewModel(widget.connection.binary),
      builder: (context, viewModel, child) {
        final theme = SailTheme.of(context);

        final baseDir = viewModel.binary.directories.base[viewModel.os];
        final downloadFile = viewModel.binary.metadata.downloadConfig.files[viewModel.os];

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
                    ],
                  ),
                  const SizedBox(height: 24),
                  StaticField(label: 'Version', value: viewModel.binary.version, copyable: true),
                  if (viewModel.binary.repoUrl.isNotEmpty)
                    StaticField(label: 'Repository', value: viewModel.binary.repoUrl, copyable: true),
                  StaticField(label: 'Host', value: widget.connection.conf.host, copyable: true),
                  StaticField(label: 'Port', value: widget.connection.binary.port.toString(), copyable: true),
                  if (args.isNotEmpty)
                    StaticField(label: 'Binary Arguments', value: args.join(' \\\n'), copyable: true),
                  StaticField(
                    label: 'Chain Layer',
                    value: viewModel.binary.chainLayer == 1 ? 'Layer 1' : 'Layer 2',
                    copyable: true,
                  ),
                  if (baseDir != null) StaticField(label: 'Installation Directory', value: baseDir, copyable: true),
                  StaticField(
                    label: 'Binary Data Directory',
                    value: viewModel.binary.datadir(),
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
                  if (downloadFile != null) viewModel.buildInfoRow(context, 'Download File', downloadFile),
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
                      SailButton(
                        label: 'Delete ${widget.connection.binary.name} data',
                        onPressed: () async {
                          final binaryProvider = GetIt.I.get<BinaryProvider>();
                          final appDir = GetIt.I.get<BinaryProvider>().appDir;

                          setState(() {
                            deleteMessage = 'Deleting data';
                          });

                          await widget.connection.binary.wipeAsset(binDir(appDir.path));
                          await widget.connection.binary.wipeAppDir();
                          await copyBinariesFromAssets(GetIt.I.get<Logger>(), appDir);

                          setState(() {
                            deleteMessage = 'Rebooting';
                          });

                          // everything's deleted, reboot the binary
                          await binaryProvider.stop(widget.connection.binary);
                          await Future.delayed(const Duration(seconds: 5));
                          await binaryProvider.start(widget.connection.binary);
                          setState(() {
                            deleteMessage = 'Delete complete';
                          });
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },

                        variant: ButtonVariant.destructive,
                        loadingLabel: deleteMessage,
                      ),
                      SailButton(label: 'Close', onPressed: () async => Navigator.pop(context)),
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

      bool wasRunning = _binaryProvider.isRunning(_binary);
      if (wasRunning) {
        // 2. Stop the binary
        await _binaryProvider.stop(_binary);

        // 3. Start the binary with retry logic (3 attempts, 5 second wait)
        bool started = false;
        int attempts = 0;
        const maxAttempts = 3;
        const retryDelay = Duration(seconds: 5);

        while (!started && attempts < maxAttempts) {
          attempts++;
          try {
            await _binaryProvider.start(_binary);
            started = true;
          } catch (e) {
            if (attempts < maxAttempts) {
              // Wait before retry
              await Future.delayed(retryDelay);
            } else {
              // Re-throw the error on final attempt
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
    await _binary.wipeAsset(binDir(appDir.path));
    await _binary.wipeAppDir();
  }

  Widget buildInfoRow(BuildContext context, String label, String value) {
    final theme = SailTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13(
            label,
            color: theme.colors.textTertiary,
          ),
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
