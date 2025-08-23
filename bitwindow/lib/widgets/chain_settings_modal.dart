import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class ChainSettingsModal extends StatefulWidget {
  final Binary binary;

  const ChainSettingsModal({
    super.key,
    required this.binary,
  });

  @override
  State<ChainSettingsModal> createState() => _ChainSettingsModalState();
}

class _ChainSettingsModalState extends State<ChainSettingsModal> {
  final BinaryProvider _binaryProvider = GetIt.I.get<BinaryProvider>();
  Directory get bitwindowAppDir => _binaryProvider.bitwindowAppDir;

  OS get os => getOS();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final baseDir = widget.binary.directories.base[os];
    final downloadFile = widget.binary.metadata.files[os];

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
                  SailText.primary20('${widget.binary.name} Settings'),
                  // Update button
                  if (widget.binary.updateAvailable)
                    SailButton(
                      label: 'Update',
                      onPressed: () async {
                        try {
                          // 1. Download the updated binary
                          await _binaryProvider.download(widget.binary, shouldUpdate: true);

                          // 2. Stop the binary
                          await _binaryProvider.stop(widget.binary);

                          // 3. Start the binary with retry logic (3 attempts, 5 second wait)
                          bool started = false;
                          int attempts = 0;
                          const maxAttempts = 3;
                          const retryDelay = Duration(seconds: 5);

                          while (!started && attempts < maxAttempts) {
                            attempts++;
                            try {
                              await _binaryProvider.start(widget.binary);
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
                        } catch (e) {
                          // Handle any errors during the update process
                          // You might want to show a snackbar or dialog here
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(context, 'Version', widget.binary.version),
              if (widget.binary.repoUrl.isNotEmpty) _buildInfoRow(context, 'Repository', widget.binary.repoUrl),
              _buildInfoRow(context, 'Network Port', widget.binary.port.toString()),
              _buildInfoRow(context, 'Chain Layer', widget.binary.chainLayer == 1 ? 'Layer 1' : 'Layer 2'),
              if (baseDir != null) _buildInfoRow(context, 'Installation Directory', baseDir),
              _buildInfoRow(context, 'Binary Path', widget.binary.metadata.binaryPath?.path ?? 'N/A'),
              if (downloadFile != null) _buildInfoRow(context, 'Download File', downloadFile),
              _buildInfoRow(
                context,
                'Latest Release At',
                widget.binary.metadata.remoteTimestamp?.toLocal().toString() ?? 'N/A',
              ),
              _buildInfoRow(
                context,
                'Your Version Installed At',
                widget.binary.metadata.downloadedTimestamp?.toLocal().toString() ?? 'N/A',
              ),
              const SizedBox(height: 24),
              SailButton(
                label: 'Delete ${widget.binary.name}',
                onPressed: () async {
                  await widget.binary.wipeAsset(binDir(bitwindowAppDir.path));
                  await widget.binary.wipeAppDir();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  if (context.mounted) {
                    showSnackBar(context, 'Deleted ${widget.binary.name} binary including all blockchain data');
                  }
                },
                variant: ButtonVariant.destructive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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
}
