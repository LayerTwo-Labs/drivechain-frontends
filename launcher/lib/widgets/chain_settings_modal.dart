import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launcher/env.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

class ChainSettingsModal extends StatefulWidget {
  final Binary chain;
  final Function() onWipeAppDir;
  final bool useStarter;
  final Function(bool) onUseStarterChanged;

  const ChainSettingsModal({
    super.key,
    required this.chain,
    required this.onWipeAppDir,
    required this.useStarter,
    required this.onUseStarterChanged,
  });

  @override
  State<ChainSettingsModal> createState() => _ChainSettingsModalState();
}

class _ChainSettingsModalState extends State<ChainSettingsModal> {
  OS get os => getOS();
  bool _useStarter = false;

  @override
  void initState() {
    super.initState();
    _useStarter = widget.useStarter;
  }

  void _openDownloadLocation(Binary binary) async {
    final baseDir = binary.directories.base[os];
    if (baseDir == null) return;

    final appDir = await Environment.appDir();

    await openDir(appDir);
  }

  Future<bool> _starterExists(Binary binary) async {
    if (binary.chainLayer != 2) {
      return false;
    }

    if (binary is! Sidechain) return false;

    try {
      final appDir = await Environment.appDir();
      final starterDir = path.join(appDir.path, 'wallet_starters');
      final starterFile = File(
        path.join(
          starterDir,
          'sidechain_${binary.slot}_starter.txt',
        ),
      );

      return starterFile.existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final baseDir = widget.chain.directories.base[os];
    final binary = widget.chain.binary;
    final downloadFile = widget.chain.metadata.files[os];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SailCard(
        padding: true,
        withCloseButton: true,
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
                    SailText.primary20('${widget.chain.name} Settings'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: SailColorScheme.red),
                      onPressed: widget.onWipeAppDir,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow(context, 'Version', widget.chain.version),
                if (widget.chain.repoUrl.isNotEmpty) _buildInfoRow(context, 'Repository', widget.chain.repoUrl),
                _buildInfoRow(context, 'Network Port', widget.chain.network.port.toString()),
                _buildInfoRow(context, 'Chain Layer', widget.chain.chainLayer == 1 ? 'Layer 1' : 'Layer 2'),
                if (baseDir != null) _buildInfoRow(context, 'Installation Directory', baseDir),
                _buildInfoRow(context, 'Binary Path', binary),
                if (downloadFile != null) _buildInfoRow(context, 'Download File', downloadFile),
                _buildInfoRow(
                  context,
                  'Latest Release At',
                  widget.chain.metadata.remoteTimestamp?.toLocal().toString() ?? 'N/A',
                ),
                _buildInfoRow(
                  context,
                  'Your Version',
                  widget.chain.metadata.downloadedTimestamp?.toLocal().toString() ?? 'N/A',
                ),
                if (widget.chain.chainLayer == 2) ...[
                  const SizedBox(height: 16),
                  FutureBuilder<bool>(
                    future: _starterExists(widget.chain),
                    builder: (context, snapshot) {
                      final starterExists = snapshot.data ?? false;
                      return Row(
                        children: [
                          SailCheckbox(
                            value: starterExists ? _useStarter : false,
                            onChanged: starterExists
                                ? (value) {
                                    setState(() {
                                      _useStarter = value;
                                      widget.onUseStarterChanged(value);
                                    });
                                  }
                                : null,
                          ),
                          const SizedBox(width: 8),
                          SailText.secondary13('Use starter'),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                if (baseDir != null)
                  Center(
                    child: SailButton(
                      label: 'Open Installation Directory',
                      onPressed: () async => _openDownloadLocation(widget.chain),
                      variant: ButtonVariant.primary,
                    ),
                  ),
              ],
            ),
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
