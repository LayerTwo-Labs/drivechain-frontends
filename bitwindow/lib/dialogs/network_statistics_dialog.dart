import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class NetworkStatisticsPage extends StatefulWidget {
  const NetworkStatisticsPage({super.key});

  @override
  State<NetworkStatisticsPage> createState() => _NetworkStatisticsPageState();
}

class _NetworkStatisticsPageState extends State<NetworkStatisticsPage> {
  final NetworkProvider _networkProvider = GetIt.I.get<NetworkProvider>();

  GetNetworkStatsResponse? get stats => _networkProvider.stats;
  List<BandwidthDataPoint> get bandwidthHistory => _networkProvider.bandwidthHistory;
  String? get error => _networkProvider.error;
  bool get isLoading => stats == null && error == null;

  @override
  void initState() {
    super.initState();
    _networkProvider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _networkProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SailDialog(
      title: 'Network Statistics',
      subtitle: 'Real-time Bitcoin network metrics with bandwidth graph',
      maxWidth: 900,
      maxHeight: 700,
      child: isLoading && stats == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colors.error,
                    ),
                    const SizedBox(height: 16),
                    SailText.primary15('Error loading network statistics'),
                    const SizedBox(height: 8),
                    SailText.secondary13(error!),
                    const SizedBox(height: 24),
                    SailButton(
                      label: 'Retry',
                      onPressed: () async {
                        await _networkProvider.fetch();
                      },
                    ),
                  ],
                ),
              ),
            )
          : stats != null
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Blockchain',
                      [
                        _buildStatRow('Block Height', stats!.blockHeight.toString()),
                        _buildStatRow('Average Block Time', '${stats!.avgBlockTime.toStringAsFixed(1)}s'),
                        _buildStatRow('Difficulty', stats!.difficulty > 0 ? stats!.difficulty.toString() : 'N/A'),
                        _buildStatRow(
                          'Network Hashrate',
                          stats!.networkHashrate > 0 ? _formatHashrate(stats!.networkHashrate) : 'N/A',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      'Network',
                      [
                        _buildStatRow('Total Peers', stats!.peerCount.toString()),
                        _buildStatRow('Inbound Connections', stats!.connectionsIn.toString()),
                        _buildStatRow('Outbound Connections', stats!.connectionsOut.toString()),
                        _buildStatRow(
                          'Network Version',
                          stats!.networkVersion > 0 ? stats!.networkVersion.toString() : 'N/A',
                        ),
                        if (stats!.subversion.isNotEmpty) _buildStatRow('Subversion', stats!.subversion),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      'Data Transfer',
                      [
                        _buildStatRow(
                          'Total Received',
                          stats!.totalBytesReceived > 0 ? _formatBytes(stats!.totalBytesReceived.toInt()) : 'N/A',
                        ),
                        _buildStatRow(
                          'Total Sent',
                          stats!.totalBytesSent > 0 ? _formatBytes(stats!.totalBytesSent.toInt()) : 'N/A',
                        ),
                      ],
                    ),
                    if (bandwidthHistory.length > 1) ...[
                      const SizedBox(height: 32),
                      _buildBandwidthGraph(),
                    ],
                    if (stats!.hasBitcoindBandwidth() || stats!.hasEnforcerBandwidth()) ...[
                      const SizedBox(height: 32),
                      _buildSection(
                        'Process Bandwidth',
                        [
                          if (stats!.hasBitcoindBandwidth()) ...[
                            _buildStatRow('bitcoind PID', stats!.bitcoindBandwidth.pid.toString()),
                            _buildStatRow(
                              'bitcoind RX',
                              '${_formatBytes(stats!.bitcoindBandwidth.totalRxBytes.toInt())} (${_formatBandwidth(stats!.bitcoindBandwidth.rxBytesPerSec)})',
                            ),
                            _buildStatRow(
                              'bitcoind TX',
                              '${_formatBytes(stats!.bitcoindBandwidth.totalTxBytes.toInt())} (${_formatBandwidth(stats!.bitcoindBandwidth.txBytesPerSec)})',
                            ),
                            _buildStatRow(
                              'bitcoind Connections',
                              stats!.bitcoindBandwidth.connectionCount.toString(),
                            ),
                          ],
                          if (stats!.hasEnforcerBandwidth()) ...[
                            const SizedBox(height: 16),
                            _buildStatRow('enforcer PID', stats!.enforcerBandwidth.pid.toString()),
                            _buildStatRow(
                              'enforcer RX',
                              '${_formatBytes(stats!.enforcerBandwidth.totalRxBytes.toInt())} (${_formatBandwidth(stats!.enforcerBandwidth.rxBytesPerSec)})',
                            ),
                            _buildStatRow(
                              'enforcer TX',
                              '${_formatBytes(stats!.enforcerBandwidth.totalTxBytes.toInt())} (${_formatBandwidth(stats!.enforcerBandwidth.txBytesPerSec)})',
                            ),
                            _buildStatRow(
                              'enforcer Connections',
                              stats!.enforcerBandwidth.connectionCount.toString(),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: SailText.secondary12(
                        'Auto-refreshing every 5 seconds',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20(title),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary13(label),
          SailText.primary15(value),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatBandwidth(double bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(1)} B/s';
    if (bytesPerSec < 1024 * 1024) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String _formatHashrate(double hashrate) {
    if (hashrate < 1000) return '${hashrate.toStringAsFixed(0)} H/s';
    if (hashrate < 1000000) return '${(hashrate / 1000).toStringAsFixed(2)} KH/s';
    if (hashrate < 1000000000) return '${(hashrate / 1000000).toStringAsFixed(2)} MH/s';
    if (hashrate < 1000000000000) return '${(hashrate / 1000000000).toStringAsFixed(2)} GH/s';
    return '${(hashrate / 1000000000000).toStringAsFixed(2)} TH/s';
  }

  Widget _buildBandwidthGraph() {
    final theme = context.sailTheme;

    // Calculate bandwidth rates from cumulative totals
    final List<FlSpot> rxSpots = [];
    final List<FlSpot> txSpots = [];

    for (int i = 1; i < bandwidthHistory.length; i++) {
      final prev = bandwidthHistory[i - 1];
      final curr = bandwidthHistory[i];
      final timeDiff = curr.time.difference(prev.time).inSeconds;

      if (timeDiff > 0) {
        final rxRate = (curr.totalRxBytes - prev.totalRxBytes) / timeDiff;
        final txRate = (curr.totalTxBytes - prev.totalTxBytes) / timeDiff;

        rxSpots.add(FlSpot(i.toDouble(), rxRate));
        txSpots.add(FlSpot(i.toDouble(), txRate));
      }
    }

    if (rxSpots.isEmpty || txSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find max value for Y axis scaling
    final maxRx = rxSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxTx = txSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxY = (maxRx > maxTx ? maxRx : maxTx) * 1.1; // Add 10% padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Bandwidth Graph'),
        const SizedBox(height: 8),
        SailText.secondary13('Last ${bandwidthHistory.length * 5} seconds'),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: maxY / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colors.backgroundSecondary,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: theme.colors.backgroundSecondary,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return SailText.secondary12(_formatBandwidth(value));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      final seconds = (bandwidthHistory.length - value.toInt()) * 5;
                      return SailText.secondary12('-${seconds}s');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: theme.colors.backgroundSecondary),
              ),
              minX: 1,
              maxX: bandwidthHistory.length.toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                // Received (green)
                LineChartBarData(
                  spots: rxSpots,
                  isCurved: true,
                  color: theme.colors.success,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colors.success.withValues(alpha: 0.1),
                  ),
                ),
                // Sent (orange)
                LineChartBarData(
                  spots: txSpots,
                  isCurved: true,
                  color: theme.colors.orange,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colors.orange.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final label = spot.barIndex == 0 ? 'RX' : 'TX';
                      return LineTooltipItem(
                        '$label: ${_formatBandwidth(spot.y)}',
                        TextStyle(
                          color: theme.colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colors.success,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            SailText.secondary13('Received'),
            const SizedBox(width: 24),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colors.orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            SailText.secondary13('Sent'),
          ],
        ),
      ],
    );
  }
}
