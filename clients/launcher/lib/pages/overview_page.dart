import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:launcher/models/chain_config.dart';
import 'package:launcher/services/configuration_service.dart';
import 'package:launcher/services/download_manager.dart';
import 'package:launcher/services/resource_downloader.dart';
import 'package:launcher/services/service_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/buttons/button.dart';

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton.primary(
                  'Download All',
                  onPressed: () => _downloadManager.downloadAllComponents(),
                  size: ButtonSize.regular,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<Map<String, DownloadProgress>>(
              stream: _downloadManager.statusStream,
              builder: (context, statusSnapshot) {
                return ListView.builder(
                  itemCount: _configService.configs.chains.length,
                  itemBuilder: (context, index) {
                    final chain = _configService.configs.chains[index];
                    final status = statusSnapshot.data?[chain.id];
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: SailRawCard(
                        padding: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SailText.primary24(chain.displayName),
                                _buildStatusIndicator(status),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SailText.secondary13('ID: ${chain.id}'),
                            SailText.secondary13('Version: ${chain.version}'),
                            SailText.secondary13(
                              'Type: ${chain.chainType == 0 ? "L1" : "L2"}',
                            ),
                            SailText.secondary13('Slot: ${chain.slot}'),
                            const SizedBox(height: 10),
                            SailText.secondary13(chain.description),
                            if (chain.repoUrl.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SailText.secondary13('Repo: ${chain.repoUrl}'),
                            ],
                            const SizedBox(height: 16),
                            _buildProgressIndicator(status),
                            if (status?.error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SailText.secondary13(
                                  status!.error!,
                                  color: Colors.red,
                                ),
                              ),
                            const SizedBox(height: 10),
                            _buildActionButton(chain.id, status),
                          ],
                        ),
                      ),
                    );
                  },
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
      DownloadStatus.downloading || 
      DownloadStatus.extracting || 
      DownloadStatus.verifying => Colors.blue,
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
}
