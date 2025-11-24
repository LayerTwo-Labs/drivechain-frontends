import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class TrafficGraphViewModel extends BaseViewModel {
  final NetworkProvider _networkProvider = GetIt.I.get<NetworkProvider>();

  TrafficGraphViewModel() {
    _networkProvider.addListener(notifyListeners);
  }

  List<BandwidthDataPoint> get bandwidthHistory => _networkProvider.bandwidthHistory;
  double get currentRxRate => _networkProvider.currentRxRate;
  double get currentTxRate => _networkProvider.currentTxRate;

  @override
  void dispose() {
    _networkProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class TrafficGraphWidget extends StatelessWidget {
  const TrafficGraphWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TrafficGraphViewModel>.reactive(
      viewModelBuilder: () => TrafficGraphViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Network Traffic',
          subtitle: 'Bandwidth over time',
          child: model.bandwidthHistory.length > 1
              ? TrafficGraphContent(
                  bandwidthHistory: model.bandwidthHistory,
                  currentRxRate: model.currentRxRate,
                  currentTxRate: model.currentTxRate,
                )
              : const TrafficGraphPlaceholder(),
        );
      },
    );
  }
}

class TrafficGraphPlaceholder extends StatelessWidget {
  const TrafficGraphPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: SailColumn(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SailSVG.icon(
              SailSVGAsset.iconTransactions,
              width: 32,
              color: context.sailTheme.colors.textTertiary,
            ),
            SailText.secondary13('Collecting network data...'),
          ],
        ),
      ),
    );
  }
}

class TrafficGraphContent extends StatelessWidget {
  final List<BandwidthDataPoint> bandwidthHistory;
  final double currentRxRate;
  final double currentTxRate;

  const TrafficGraphContent({
    super.key,
    required this.bandwidthHistory,
    required this.currentRxRate,
    required this.currentTxRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    // Build spots for the chart using rates
    final List<FlSpot> rxSpots = [];
    final List<FlSpot> txSpots = [];

    for (int i = 0; i < bandwidthHistory.length; i++) {
      final dp = bandwidthHistory[i];
      rxSpots.add(FlSpot(i.toDouble(), dp.rxBytesPerSec));
      txSpots.add(FlSpot(i.toDouble(), dp.txBytesPerSec));
    }

    // Find max value for Y axis scaling
    double maxY = 1024; // Minimum 1 KB/s
    for (final spot in rxSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    for (final spot in txSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = maxY * 1.1; // Add 10% padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrafficGraphLegend(
          currentRxRate: currentRxRate,
          currentTxRate: currentTxRate,
        ),
        const SizedBox(height: SailStyleValues.padding12),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) {
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
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return SailText.secondary12(_formatBandwidth(value));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: bandwidthHistory.length / 4,
                    getTitlesWidget: (value, meta) {
                      final seconds = (bandwidthHistory.length - value.toInt()) * 5;
                      if (seconds == 0) return SailText.secondary12('now');
                      return SailText.secondary12('-${seconds}s');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: bandwidthHistory.length.toDouble() - 1,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                // Received (green)
                LineChartBarData(
                  spots: rxSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: theme.colors.success,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colors.success.withValues(alpha: 0.15),
                  ),
                ),
                // Sent (orange)
                LineChartBarData(
                  spots: txSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: theme.colors.orange,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colors.orange.withValues(alpha: 0.15),
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
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatBandwidth(double bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(0)} B/s';
    if (bytesPerSec < 1024 * 1024) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}

class TrafficGraphLegend extends StatelessWidget {
  final double currentRxRate;
  final double currentTxRate;

  const TrafficGraphLegend({
    super.key,
    required this.currentRxRate,
    required this.currentTxRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Row(
      children: [
        LegendItem(
          color: theme.colors.success,
          label: 'Received',
          value: _formatBandwidth(currentRxRate),
        ),
        const SizedBox(width: SailStyleValues.padding20),
        LegendItem(
          color: theme.colors.orange,
          label: 'Sent',
          value: _formatBandwidth(currentTxRate),
        ),
      ],
    );
  }

  String _formatBandwidth(double bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(0)} B/s';
    if (bytesPerSec < 1024 * 1024) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        SailText.secondary12('$label:'),
        const SizedBox(width: 4),
        SailText.primary12(value),
      ],
    );
  }
}
