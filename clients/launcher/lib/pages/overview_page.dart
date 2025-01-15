import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:launcher/models/chain_config.dart';
import 'package:launcher/services/configuration_service.dart';
import 'package:launcher/services/download_manager.dart';
import 'package:launcher/services/resource_downloader.dart';
import 'package:launcher/services/service_provider.dart';
import 'package:launcher/widgets/chain_settings_modal.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late final ConfigurationService _configService;
  late final DownloadManager _downloadManager;

  @override
  void initState() {
    super.initState();
    _configService = ServiceProvider.get<ConfigurationService>();
    _downloadManager = ServiceProvider.get<DownloadManager>();
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<Map<String, DownloadProgress>>(
              stream: _downloadManager.statusStream,
              builder: (context, statusSnapshot) {
                final l1Chains = _configService.configs.chains.where((chain) => chain.chainType == 0).toList()
                  ..sort((a, b) => a.slot.compareTo(b.slot));
                final l2Chains = _configService.configs.chains.where((chain) => chain.chainType == 1).toList();

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary24('Layer 1'),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final availableWidth = constraints.maxWidth;
                                final cardWidth = availableWidth >= 900
                                    ? (availableWidth - (3 * 16)) / 4 // 4 cards with 16px spacing
                                    : (availableWidth - 16) / 2; // 2 cards with 16px spacing

                                return Wrap(
                                  spacing: 16.0,
                                  runSpacing: 16.0,
                                  children: l1Chains.map((chain) {
                                    final status = statusSnapshot.data?[chain.id];
                                    return SizedBox(
                                      width: cardWidth,
                                      child: SailRawCard(
                                        padding: true,
                                        child: _buildChainContent(chain, status),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary24('Layer 2'),
                            const SizedBox(height: 16),
                            ...l2Chains.map((chain) {
                              final status = statusSnapshot.data?[chain.id];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 8.0,
                                ),
                                child: SailRawCard(
                                  padding: true,
                                  child: _buildChainContent(chain, status),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(DownloadProgress? status) {
    if (status == null) return const SizedBox();

    final color = switch (status.status) {
      DownloadStatus.completed => Colors.green,
      DownloadStatus.failed => Colors.red,
      DownloadStatus.downloading || DownloadStatus.extracting || DownloadStatus.verifying => Colors.blue,
      _ => Colors.grey,
    };

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressIndicator(DownloadProgress? status) {
    if (status == null) return const SizedBox();

    if (status.status == DownloadStatus.downloading ||
        status.status == DownloadStatus.extracting ||
        status.status == DownloadStatus.verifying) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: status.progress),
          const SizedBox(height: 4),
          SailText.secondary13(status.message ?? ''),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildActionButton(String componentId, DownloadProgress? status) {
    if (status == null || status.status == DownloadStatus.notStarted) {
      return SailButton.primary(
        'Download',
        onPressed: () => _downloadManager.downloadComponent(componentId),
        size: ButtonSize.regular,
      );
    }

    if (status.status == DownloadStatus.failed) {
      return SailButton.primary(
        'Retry',
        onPressed: () => _downloadManager.downloadComponent(componentId),
        size: ButtonSize.regular,
      );
    }

    if (status.status == DownloadStatus.completed) {
      return SailButton.secondary(
        'Verify',
        onPressed: () => _downloadManager.verifyComponent(componentId),
        size: ButtonSize.regular,
      );
    }

    return const SizedBox();
  }

  Widget _buildChainContent(ChainConfig chain, DownloadProgress? status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SailText.primary24(
                chain.displayName,
                textAlign: TextAlign.left,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ChainSettingsModal(chain: chain),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildStatusIndicator(status),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          child: SailText.secondary13(
            chain.description,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressIndicator(status),
        if (status?.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SailText.secondary13(
              status!.error!,
              color: Colors.red,
            ),
          ),
        const SizedBox(height: 8),
        _buildActionButton(chain.id, status),
      ],
    );
  }
}
