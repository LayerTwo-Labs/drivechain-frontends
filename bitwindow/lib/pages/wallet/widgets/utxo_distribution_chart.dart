import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';

class UTXODistributionChart extends StatefulWidget {
  final String walletId;
  final void Function(List<String> outpoints)? onBucketTap;
  final void Function(UTXOBucket bucket, Offset position)? onBucketContextMenu;
  final void Function(List<UTXOBucket> smallBuckets)? onConsolidate;

  const UTXODistributionChart({
    super.key,
    required this.walletId,
    this.onBucketTap,
    this.onBucketContextMenu,
    this.onConsolidate,
  });

  @override
  State<UTXODistributionChart> createState() => _UTXODistributionChartState();
}

class _UTXODistributionChartState extends State<UTXODistributionChart> {
  GetUTXODistributionResponse? _distribution;
  bool _isLoading = true;
  String? _error;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadDistribution();
  }

  @override
  void didUpdateWidget(UTXODistributionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.walletId != oldWidget.walletId) {
      _loadDistribution();
    }
  }

  Future<void> _loadDistribution() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rpc = GetIt.I<BitwindowRPC>();
      final response = await rpc.wallet.getUTXODistribution(widget.walletId, maxBuckets: 8);
      if (mounted) {
        setState(() {
          _distribution = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (_isLoading) {
      return SizedBox(
        height: 180,
        child: Center(
          child: SailCircularProgressIndicator(color: theme.colors.text),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 180,
        child: Center(
          child: SailText.secondary12('Failed to load distribution'),
        ),
      );
    }

    if (_distribution == null || _distribution!.buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final buckets = _distribution!.buckets;
    final totalValue = buckets.fold<double>(0, (sum, b) => sum + b.valueSats.toDouble());

    // Find small UTXOs (less than 1% of total, or in "Other" bucket)
    final smallBuckets = buckets.where((b) {
      final percentage = totalValue > 0 ? (b.valueSats.toDouble() / totalValue) * 100 : 0;
      return percentage < 5 || b.label.startsWith('Other');
    }).toList();
    final hasSmallUtxos = smallBuckets.isNotEmpty && smallBuckets.fold<int>(0, (sum, b) => sum + b.count) > 1;

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });

                    // Handle tap
                    if (event is FlTapUpEvent && _touchedIndex >= 0 && _touchedIndex < buckets.length) {
                      final outpoints = buckets[_touchedIndex].outpoints;
                      widget.onBucketTap?.call(outpoints);
                    }
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: _buildSections(buckets, totalValue, theme),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Legend and actions
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: _buildLegend(buckets, totalValue, theme),
                ),
                if (hasSmallUtxos && widget.onConsolidate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: SailStyleValues.padding08),
                    child: SailButton(
                      label: 'Consolidate Small UTXOs',
                      variant: ButtonVariant.secondary,
                      small: true,
                      onPressed: () async {
                        widget.onConsolidate?.call(smallBuckets);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    List<UTXOBucket> buckets,
    double totalValue,
    SailThemeData theme,
  ) {
    final colors = [
      theme.colors.info,
      theme.colors.success,
      theme.colors.orange,
      theme.colors.error,
      const Color(0xFF9C27B0), // purple
      const Color(0xFF00BCD4), // cyan
      const Color(0xFFFF9800), // amber
      const Color(0xFF795548), // brown
    ];

    return buckets.asMap().entries.map((entry) {
      final index = entry.key;
      final bucket = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = totalValue > 0 ? (bucket.valueSats.toDouble() / totalValue) * 100 : 0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: bucket.valueSats.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: isTouched ? 55 : 50,
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildLegend(List<UTXOBucket> buckets, double totalValue, SailThemeData theme) {
    final colors = [
      theme.colors.info,
      theme.colors.success,
      theme.colors.orange,
      theme.colors.error,
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
      const Color(0xFF795548),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buckets.length,
      itemBuilder: (context, index) {
        final bucket = buckets[index];
        final percentage = totalValue > 0 ? (bucket.valueSats.toDouble() / totalValue) * 100 : 0;
        final isHovered = index == _touchedIndex;

        return MouseRegion(
          onEnter: (_) => setState(() => _touchedIndex = index),
          onExit: (_) => setState(() => _touchedIndex = -1),
          child: GestureDetector(
            onTap: () => widget.onBucketTap?.call(bucket.outpoints),
            onSecondaryTapUp: (details) {
              widget.onBucketContextMenu?.call(bucket, details.globalPosition);
            },
            onLongPressStart: (details) {
              widget.onBucketContextMenu?.call(bucket, details.globalPosition);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              decoration: BoxDecoration(
                color: isHovered ? theme.colors.backgroundSecondary : Colors.transparent,
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SailText.primary12(
                      bucket.label,
                      monospace: true,
                    ),
                  ),
                  SailText.secondary12(
                    '${bucket.count} ${bucket.count == 1 ? 'UTXO' : 'UTXOs'}',
                  ),
                  const SizedBox(width: 12),
                  SailText.primary12(
                    '${percentage.toStringAsFixed(0)}%',
                    monospace: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
