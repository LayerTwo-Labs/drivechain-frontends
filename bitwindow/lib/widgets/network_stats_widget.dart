import 'package:bitwindow/providers/network_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class NetworkStatsViewModel extends BaseViewModel {
  final NetworkProvider _networkProvider = GetIt.I.get<NetworkProvider>();

  NetworkStatsViewModel() {
    _networkProvider.addListener(notifyListeners);
  }

  GetNetworkStatsResponse? get stats => _networkProvider.stats;
  double get currentRxRate => _networkProvider.currentRxRate;
  double get currentTxRate => _networkProvider.currentTxRate;

  @override
  void dispose() {
    _networkProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class NetworkStatsWidget extends StatelessWidget {
  const NetworkStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NetworkStatsViewModel>.reactive(
      viewModelBuilder: () => NetworkStatsViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Network Stats',
          subtitle: 'Connection summary',
          widgetHeaderEnd: SailButton(
            label: 'Details',
            variant: ButtonVariant.ghost,
            onPressed: () async {
              await GetIt.I.get<AppRouter>().push(NetworkStatisticsRoute());
            },
          ),
          child: model.stats != null
              ? NetworkStatsContent(
                  stats: model.stats!,
                  currentRxRate: model.currentRxRate,
                  currentTxRate: model.currentTxRate,
                )
              : const NetworkStatsPlaceholder(),
        );
      },
    );
  }
}

class NetworkStatsPlaceholder extends StatelessWidget {
  const NetworkStatsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: SailText.secondary13('Loading network stats...'),
      ),
    );
  }
}

class NetworkStatsContent extends StatelessWidget {
  final GetNetworkStatsResponse stats;
  final double currentRxRate;
  final double currentTxRate;

  const NetworkStatsContent({
    super.key,
    required this.stats,
    required this.currentRxRate,
    required this.currentTxRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatItem(
                label: 'Peers',
                value: stats.peerCount.toString(),
                subtitle: '${stats.connectionsIn} in / ${stats.connectionsOut} out',
              ),
            ),
            Expanded(
              child: StatItem(
                label: 'Block Height',
                value: stats.blockHeight.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: SailStyleValues.padding16),
        Row(
          children: [
            Expanded(
              child: StatItem(
                label: 'Download',
                value: _formatBandwidth(currentRxRate),
                subtitle: _formatBytes(stats.totalBytesReceived.toInt()),
              ),
            ),
            Expanded(
              child: StatItem(
                label: 'Upload',
                value: _formatBandwidth(currentTxRate),
                subtitle: _formatBytes(stats.totalBytesSent.toInt()),
              ),
            ),
          ],
        ),
        if (stats.hasBitcoindBandwidth()) ...[
          const SizedBox(height: SailStyleValues.padding16),
          Row(
            children: [
              Expanded(
                child: StatItem(
                  label: 'bitcoind',
                  value: '${stats.bitcoindBandwidth.connectionCount} conn',
                  subtitle: 'PID ${stats.bitcoindBandwidth.pid}',
                ),
              ),
              if (stats.hasEnforcerBandwidth())
                Expanded(
                  child: StatItem(
                    label: 'enforcer',
                    value: '${stats.enforcerBandwidth.connectionCount} conn',
                    subtitle: 'PID ${stats.enforcerBandwidth.pid}',
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatBandwidth(double bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(0)} B/s';
    if (bytesPerSec < 1024 * 1024) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B total';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB total';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB total';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB total';
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        const SizedBox(height: 4),
        SailText.primary15(value),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          SailText.secondary12(subtitle!),
        ],
      ],
    );
  }
}
