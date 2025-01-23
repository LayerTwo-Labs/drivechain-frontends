import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launcher/env.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/utils/file_utils.dart';

class ChainSettingsModal extends StatelessWidget {
  final Binary chain;
  final Function() onWipeAppDir;
  final Function() onWipeWallet;
  OS get os => getOS();

  const ChainSettingsModal({
    super.key,
    required this.chain,
    required this.onWipeAppDir,
    required this.onWipeWallet,
  });

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
                        icon: const Icon(Icons.delete, color: SailColorScheme.red),
                        onPressed: onWipeAppDir,
                      ),
                      IconButton(
                        icon: const Icon(Icons.wallet, color: SailColorScheme.red),
                        onPressed: onWipeWallet,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = SailTheme.of(context);
    final isPath = label.contains('Directory') || label.contains('Path') || label.contains('File');

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
          InkWell(
            onTap: isPath ? () async {
              final fullPath = switch (label) {
                'Installation Directory' => chain.datadir(),
                'Binary Path' => path.dirname(chain.assetPath(await Environment.appDir())),
                'Download File' => path.dirname(path.join((await Environment.appDir()).path, 'assets', 'downloads', value)),
                _ => null
              };
              if (fullPath != null) {
                await openDir(Directory(fullPath));
              }
            } : null,
            child: isPath 
              ? Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                )
              : SailText.primary13(value),
          ),
        ],
      ),
    );
  }
}
