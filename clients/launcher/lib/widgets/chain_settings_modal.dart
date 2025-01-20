import 'package:flutter/material.dart';
import 'package:launcher/env.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/utils/file_utils.dart';

class ChainSettingsModal extends StatelessWidget {
  final Binary chain;
  OS get os => getOS();

  const ChainSettingsModal({
    super.key,
    required this.chain,
  });

  void _openDownloadLocation(Binary binary) async {
    final baseDir = binary.directories.base[os];
    if (baseDir == null) return;

    final appDir = await Environment.appDir();

    await openDir(appDir);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final baseDir = chain.directories.base[os];
    final binary = chain.binary;
    final downloadFile = chain.download.files[os];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        height: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.primary20('${chain.name} Settings'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => chain.wipeAppDir(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.colors.text),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(context, 'Version', chain.version),
              if (chain.repoUrl.isNotEmpty) _buildInfoRow(context, 'Repository', chain.repoUrl),
              _buildInfoRow(context, 'Network Port', chain.network.port.toString()),
              _buildInfoRow(context, 'Chain Layer', chain.chainLayer == 1 ? 'Layer 1' : 'Layer 2'),
              if (baseDir != null) _buildInfoRow(context, 'Installation Directory', baseDir),
              _buildInfoRow(context, 'Binary Path', binary),
              if (downloadFile != null) _buildInfoRow(context, 'Download File', downloadFile),
              _buildInfoRow(
                context,
                'Latest Release At',
                chain.download.remoteTimestamp?.toLocal().toString() ?? 'N/A',
              ),
              _buildInfoRow(
                context,
                'Your Version',
                chain.download.downloadedTimestamp?.toLocal().toString() ?? 'N/A',
              ),
              const SizedBox(height: 24),
              if (baseDir != null)
                Center(
                  child: SailButton.primary(
                    'Open Installation Directory',
                    onPressed: () => _openDownloadLocation(chain),
                    size: ButtonSize.regular,
                  ),
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
