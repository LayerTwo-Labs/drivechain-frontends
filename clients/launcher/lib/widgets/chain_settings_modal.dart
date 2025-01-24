import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launcher/env.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/utils/file_utils.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

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
    // final downloadFile = chain.download.files[os];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailText.primary20('${chain.name} Settings'),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete, color: SailColorScheme.red),
                          onPressed: onWipeAppDir,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.wallet, color: SailColorScheme.red),
                          onPressed: onWipeWallet,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.close, color: theme.colors.text),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // TODO: Update these fields later
              // _buildInfoRow(context, 'Version', chain.version),
              if (chain.repoUrl.isNotEmpty) _buildInfoRow(context, 'Repository', chain.repoUrl),
              _buildInfoRow(context, 'Network Port', chain.network.port.toString()),
              // _buildInfoRow(context, 'Chain Layer', chain.chainLayer == 1 ? 'Layer 1' : 'Layer 2'),
              if (baseDir != null) _buildInfoRow(context, 'Installation Directory', baseDir),
              _buildInfoRow(context, 'Binary Path', binary),
              // if (downloadFile != null) _buildInfoRow(context, 'Download File', downloadFile),
              // _buildInfoRow(
              //   context,
              //   'Latest Release At',
              //   chain.download.remoteTimestamp?.toLocal().toString() ?? 'N/A',
              // ),
              // _buildInfoRow(
              //   context,
              //   'Your Version',
              //   chain.download.downloadedTimestamp?.toLocal().toString() ?? 'N/A',
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = SailTheme.of(context);
    final isPath = label.contains('Directory') || label.contains('Path') || label.contains('File');
    final isUrl = label == 'Repository';

    return Padding(
      padding: EdgeInsets.only(bottom: _isLastVisibleRow(label) ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13(
            label,
            color: theme.colors.textTertiary,
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: isPath || isUrl ? () async {
              if (isPath) {
                final fullPath = switch (label) {
                  'Installation Directory' => Platform.isWindows && chain is ParentChain
                    ? path.join(Platform.environment['USERPROFILE']!, 'AppData', 'Local', 'drivechain')
                    : chain.datadir(),
                  'Binary Path' => path.dirname(chain.assetPath(await Environment.appDir())),
                  'Download File' => path.dirname(path.join((await Environment.appDir()).path, 'assets', 'downloads', value)),
                  _ => null
                };
                if (fullPath != null) {
                  await openDir(Directory(fullPath));
                }
              } else if (isUrl) {
                final uri = Uri.parse(value);
                await url_launcher.launchUrl(uri);
              }
            } : null,
            child: SailText.primary13(value, underline: isPath || isUrl, decoration: isPath || isUrl ? TextDecoration.underline : null),
          ),
        ],
      ),
    );
  }

  bool _isLastVisibleRow(String label) {
    final visibleRows = [
      if (chain.repoUrl.isNotEmpty) 'Repository',
      'Network Port',
      if (chain.directories.base[os] != null) 'Installation Directory',
      'Binary Path',
    ];
    return label == visibleRows.last;
  }
}
