import 'package:flutter/material.dart';
import 'package:launcher/env.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/style/color_scheme.dart';
import 'package:sail_ui/utils/file_utils.dart';
import 'package:sail_ui/widgets/buttons/button.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

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

    final datadir = await Environment.datadir();

    await openDir(datadir);
  }

  @override
  Widget build(BuildContext context) {
    final baseDir = chain.directories.base[os];
    final binary = chain.binary;
    final downloadFile = chain.download.files[os];

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
                SailText.primary20('${chain.name} Settings'),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Version', chain.version),
            if (chain.repoUrl.isNotEmpty) _buildInfoRow('Repository', chain.repoUrl),
            _buildInfoRow('Network Port', chain.network.port.toString()),
            _buildInfoRow('Chain Layer', chain.chainLayer == 1 ? 'Layer 1' : 'Layer 2'),
            if (baseDir != null) _buildInfoRow('Installation Directory', baseDir),
            _buildInfoRow('Binary Path', binary),
            if (downloadFile != null) _buildInfoRow('Download File', downloadFile),
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
