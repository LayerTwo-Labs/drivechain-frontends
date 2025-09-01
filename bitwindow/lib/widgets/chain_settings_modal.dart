import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ChainSettingsModal extends StatelessWidget {
  final Binary binary;

  const ChainSettingsModal({
    super.key,
    required this.binary,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChainSettingsViewModel>.reactive(
      viewModelBuilder: () => ChainSettingsViewModel(binary),
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
                          label: viewModel.isUpdating ? 'Updating...' : 'Update',
                          onPressed: viewModel.isUpdating ? null : () => viewModel.handleUpdate(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  viewModel.buildInfoRow(context, 'Version', viewModel.binary.version),
                  if (viewModel.binary.repoUrl.isNotEmpty)
                    viewModel.buildInfoRow(context, 'Repository', viewModel.binary.repoUrl),
                  viewModel.buildInfoRow(context, 'Network Port', viewModel.binary.port.toString()),
                  viewModel.buildInfoRow(
                    context,
                    'Chain Layer',
                    viewModel.binary.chainLayer == 1 ? 'Layer 1' : 'Layer 2',
                  ),
                  if (baseDir != null) viewModel.buildInfoRow(context, 'Installation Directory', baseDir),
                  viewModel.buildInfoRow(context, 'Binary Path', viewModel.binary.metadata.binaryPath?.path ?? 'N/A'),
                  if (downloadFile != null) viewModel.buildInfoRow(context, 'Download File', downloadFile),
                  viewModel.buildInfoRow(
                    context,
                    'Latest Release At',
                    viewModel.binary.metadata.remoteTimestamp?.toLocal().toString() ?? 'N/A',
                  ),
                  viewModel.buildInfoRow(
                    context,
                    'Your Version Installed At',
                    viewModel.binary.metadata.downloadedTimestamp?.toLocal().toString() ?? 'N/A',
                  ),
                  const SizedBox(height: 24),
                  SailButton(
                    label: 'Delete ${viewModel.binary.name}',
                    onPressed: viewModel.handleDelete,
                    variant: ButtonVariant.destructive,
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
