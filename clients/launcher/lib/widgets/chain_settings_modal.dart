import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launcher/models/chain_config.dart';
import 'package:sail_ui/style/color_scheme.dart';
import 'package:sail_ui/widgets/buttons/button.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class ChainSettingsModal extends StatelessWidget {
  final ChainConfig chain;

  const ChainSettingsModal({
    super.key,
    required this.chain,
  });

  void _openDownloadLocation(BuildContext context) {
    final platform = Platform.operatingSystem;
    final baseDir = chain.directories.base[platform];
    if (baseDir == null) return;

    final command = switch (platform) {
      'linux' => 'xdg-open',
      'macos' => 'open',
      'windows' => 'explorer',
      _ => null,
    };

    if (command != null) {
      Process.run(command, [baseDir]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = Platform.operatingSystem;
    final baseDir = chain.directories.base[platform];
    final binary = chain.binary[platform];
    final downloadFile = chain.download.files[platform];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SailColorScheme.blackLighter,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SailText.primary20('${chain.displayName} Settings'),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Version', chain.version),
            if (chain.repoUrl.isNotEmpty) 
              _buildInfoRow('Repository', chain.repoUrl),
            _buildInfoRow('Network Port', chain.network.port.toString()),
            _buildInfoRow('Chain Type', 
              chain.chainType == 0 ? 'Layer 1' : 'Layer 2'),
            _buildInfoRow('Chain Slot', chain.slot.toString()),
            if (baseDir != null)
              _buildInfoRow('Installation Directory', baseDir),
            if (binary != null)
              _buildInfoRow('Binary Path', binary),
            if (downloadFile != null)
              _buildInfoRow('Download File', downloadFile),
            if (chain.directories.wallet.isNotEmpty)
              _buildInfoRow('Wallet Path', chain.directories.wallet),
            const SizedBox(height: 24),
            if (baseDir != null)
              Center(
                child: SailButton.primary(
                  'Open Installation Directory',
                  onPressed: () => _openDownloadLocation(context),
                  size: ButtonSize.regular,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13(
            label,
            color: SailColorScheme.greyMiddle,
          ),
          const SizedBox(height: 4),
          SailText.primary13(value),
        ],
      ),
    );
  }
}
