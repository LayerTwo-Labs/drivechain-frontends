import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class FeeRateChart extends StatelessWidget {
  final List<FeeRatePoint> points;
  final int? selectedConfTarget;
  final ValueChanged<FeeRatePoint> onSelected;

  const FeeRateChart({
    super.key,
    required this.points,
    required this.selectedConfTarget,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].satPerVByte));
    }

    double maxY = 1;
    for (final p in points) {
      if (p.satPerVByte > maxY) maxY = p.satPerVByte;
    }
    maxY = maxY * 1.2;

    final selectedIndex = selectedConfTarget == null
        ? -1
        : points.indexWhere((p) => p.confTarget == selectedConfTarget);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colors.backgroundSecondary,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => SailText.secondary12(value.toStringAsFixed(value < 10 ? 1 : 0)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                  return SailText.secondary12('${points[i].confTarget}');
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: points.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              color: theme.colors.orange,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: index == selectedIndex ? 6 : 3,
                  color: index == selectedIndex ? theme.colors.primary : theme.colors.orange,
                  strokeWidth: index == selectedIndex ? 2 : 0,
                  strokeColor: theme.colors.text,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colors.orange.withValues(alpha: 0.12),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final p = points[spot.x.toInt()];
                return LineTooltipItem(
                  '${p.satPerVByte.toStringAsFixed(1)} sat/vB\n~${p.confTarget} blocks',
                  TextStyle(
                    color: theme.colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            touchCallback: (event, response) {
              if (event is! FlTapUpEvent) return;
              final spot = response?.lineBarSpots?.firstOrNull;
              if (spot == null) return;
              final i = spot.x.toInt();
              if (i < 0 || i >= points.length) return;
              onSelected(points[i]);
            },
          ),
        ),
      ),
    );
  }
}
