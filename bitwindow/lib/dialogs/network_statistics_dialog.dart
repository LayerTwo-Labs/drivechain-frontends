import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
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
    final phone = SailStyleValues.phoneLayout(context);
    final gap = phone ? SailStyleValues.padding12 : 32.0;

    return SailDialog(
      title: 'Network Statistics',
      subtitle: 'Real-time Bitcoin network metrics with bandwidth graph',
      maxWidth: 900,
      maxHeight: 700,
      child: isLoading && stats == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: LoadingIndicator(),
              ),
            )
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 48, color: theme.colors.error),
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
                padding: phone ? const EdgeInsets.only(top: SailStyleValues.padding12) : const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: phone ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
                  children: [
                    StatSection(
                      title: 'Blockchain',
                      children: [
                        StatRow(label: 'Block Height', value: stats!.blockHeight.toString()),
                        StatRow(label: 'Average Block Time', value: '${stats!.avgBlockTime.toStringAsFixed(1)}s'),
                        StatRow(
                          label: 'Difficulty',
                          value: stats!.difficulty > 0 ? stats!.difficulty.toString() : 'N/A',
                        ),
                        StatRow(
                          label: 'Network Hashrate',
                          value: stats!.networkHashrate > 0 ? _formatHashrate(stats!.networkHashrate) : 'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    StatSection(
                      title: 'Network',
                      children: [
                        StatRow(label: 'Total Peers', value: stats!.peerCount.toString()),
                        StatRow(label: 'Inbound Connections', value: stats!.connectionsIn.toString()),
                        StatRow(label: 'Outbound Connections', value: stats!.connectionsOut.toString()),
                        StatRow(
                          label: 'Network Version',
                          value: stats!.networkVersion > 0 ? stats!.networkVersion.toString() : 'N/A',
                        ),
                        if (stats!.subversion.isNotEmpty) StatRow(label: 'Subversion', value: stats!.subversion),
                      ],
                    ),
                    SizedBox(height: gap),
                    StatSection(
                      title: 'Data Transfer',
                      children: [
                        StatRow(
                          label: 'Total Received',
                          value: stats!.totalBytesReceived > 0
                              ? _formatBytes(stats!.totalBytesReceived.toInt())
                              : 'N/A',
                        ),
                        StatRow(
                          label: 'Total Sent',
                          value: stats!.totalBytesSent > 0 ? _formatBytes(stats!.totalBytesSent.toInt()) : 'N/A',
                        ),
                      ],
                    ),
                    if (bandwidthHistory.length > 1) ...[
                      SizedBox(height: gap),
                      _BandwidthGraph(
                        bandwidthHistory: bandwidthHistory,
                        formatBandwidth: _formatBandwidth,
                      ),
                    ],
                    if (stats!.hasBitcoindBandwidth() || stats!.hasEnforcerBandwidth()) ...[
                      SizedBox(height: gap),
                      StatSection(
                        title: 'Processes',
                        children: [
                          if (stats!.hasBitcoindBandwidth()) ...[
                            StatRow(label: 'bitcoind PID', value: stats!.bitcoindBandwidth.pid.toString()),
                            StatRow(
                              label: 'bitcoind Connections',
                              value: stats!.bitcoindBandwidth.connectionCount.toString(),
                            ),
                          ],
                          if (stats!.hasEnforcerBandwidth()) ...[
                            const SizedBox(height: 16),
                            StatRow(label: 'enforcer PID', value: stats!.enforcerBandwidth.pid.toString()),
                            StatRow(
                              label: 'enforcer Connections',
                              value: stats!.enforcerBandwidth.connectionCount.toString(),
                            ),
                          ],
                        ],
                      ),
                    ],
                    SizedBox(height: phone ? SailStyleValues.padding12 : 24),
                    Align(
                      alignment: phone ? Alignment.centerLeft : Alignment.center,
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatBandwidth(double bytesPerSec) {
    if (bytesPerSec < 1024) {
      return '${bytesPerSec.toStringAsFixed(1)} B/s';
    }
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String _formatHashrate(double hashrate) {
    if (hashrate < 1000) {
      return '${hashrate.toStringAsFixed(0)} H/s';
    }
    if (hashrate < 1000000) {
      return '${(hashrate / 1000).toStringAsFixed(2)} KH/s';
    }
    if (hashrate < 1000000000) {
      return '${(hashrate / 1000000).toStringAsFixed(2)} MH/s';
    }
    if (hashrate < 1000000000000) {
      return '${(hashrate / 1000000000).toStringAsFixed(2)} GH/s';
    }
    return '${(hashrate / 1000000000000).toStringAsFixed(2)} TH/s';
  }
}

/// Top of the bandwidth graph Y axis: the peak rate plus 10%, at least 1 KB/s.
double bandwidthGraphMaxY(Iterable<FlSpot> spots) {
  final peak = spots.fold<double>(1024, (max, s) => s.y > max ? s.y : max);
  return peak * 1.1;
}

class _BandwidthGraph extends StatelessWidget {
  final List<BandwidthDataPoint> bandwidthHistory;
  final String Function(double) formatBandwidth;

  const _BandwidthGraph({
    required this.bandwidthHistory,
    required this.formatBandwidth,
  });

  @override
  Widget build(BuildContext context) {
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

    final maxY = bandwidthGraphMaxY([...rxSpots, ...txSpots]);

    if (SailStyleValues.phoneLayout(context)) {
      final axis = BorderSide(color: theme.colors.divider);
      LineChartBarData line(List<FlSpot> spots, Color color) => LineChartBarData(
        spots: spots,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
      );
      return StatSection(
        title: 'Bandwidth Graph',
        children: [
          SailText.secondary13('Last ${bandwidthHistory.length * 5} seconds'),
          const SizedBox(height: SailStyleValues.padding12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border(left: axis, bottom: axis),
                ),
                minX: 1,
                maxX: bandwidthHistory.length.toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [line(rxSpots, theme.colors.orange), line(txSpots, theme.colors.info)],
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: SailStyleValues.padding12),
          Row(
            children: [
              _LegendDot(color: theme.colors.orange),
              const SizedBox(width: 6),
              SailText.secondary13('Received'),
              const SizedBox(width: SailStyleValues.padding16),
              _LegendDot(color: theme.colors.info),
              const SizedBox(width: 6),
              SailText.secondary13('Sent'),
            ],
          ),
        ],
      );
    }

    final body = [
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
                    return SailText.secondary12(formatBandwidth(value));
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
                      '$label: ${formatBandwidth(spot.y)}',
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Bandwidth Graph'),
        const SizedBox(height: 8),
        ...body,
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('bandwidth-legend-dot'),
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
