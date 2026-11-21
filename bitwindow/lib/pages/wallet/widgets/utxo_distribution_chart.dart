import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
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
                  child: _Legend(
                    buckets: buckets,
                    totalValue: totalValue,
                    touchedIndex: _touchedIndex,
                    onTouchChange: (index) => setState(() => _touchedIndex = index),
                    onBucketTap: widget.onBucketTap,
                    onBucketContextMenu: widget.onBucketContextMenu,
                  ),
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
    final colors = theme.colors.chartPalette;

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
          color: theme.colors.primaryButtonText,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }
}

class _Legend extends StatelessWidget {
  final List<UTXOBucket> buckets;
  final double totalValue;
  final int touchedIndex;
  final void Function(int) onTouchChange;
  final void Function(List<String> outpoints)? onBucketTap;
  final void Function(UTXOBucket bucket, Offset position)? onBucketContextMenu;

  const _Legend({
    required this.buckets,
    required this.totalValue,
    required this.touchedIndex,
    required this.onTouchChange,
    this.onBucketTap,
    this.onBucketContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final colors = theme.colors.chartPalette;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buckets.length,
      itemBuilder: (context, index) {
        final bucket = buckets[index];
        final percentage = totalValue > 0 ? (bucket.valueSats.toDouble() / totalValue) * 100 : 0;
        final isHovered = index == touchedIndex;

        return MouseRegion(
          onEnter: (_) => onTouchChange(index),
          onExit: (_) => onTouchChange(-1),
          child: GestureDetector(
            onTap: () => onBucketTap?.call(bucket.outpoints),
            onSecondaryTapUp: (details) {
              onBucketContextMenu?.call(bucket, details.globalPosition);
            },
            onLongPressStart: (details) {
              onBucketContextMenu?.call(bucket, details.globalPosition);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              decoration: BoxDecoration(
                color: isHovered ? theme.colors.backgroundSecondary : SailColorScheme.transparent,
                borderRadius: context.sailTheme.chrome.radiusSmall,
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
                      '${bucket.label} ${activeTicker.symbol}',
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

/// Upper bounds in sats of the phone buckets: 0.001, 0.01, 0.1, 1 and 10 coins.
const List<int> phoneBucketBounds = [100000, 1000000, 10000000, 100000000, 1000000000];
const List<String> phoneBucketLabels = ['<.001', '.001–.01', '.01–.1', '.1–1', '1–10', '>10'];

/// The coins sorted into the six phone buckets, smallest first. A bucket with no coins stays in the list.
List<UTXOBucket> phoneUtxoBuckets(List<UnspentOutput> utxos) {
  final buckets = [for (final label in phoneBucketLabels) UTXOBucket(label: label)];
  for (final utxo in utxos) {
    final sats = utxo.valueSats.toInt();
    var index = phoneBucketBounds.indexWhere((bound) => sats < bound);
    if (index < 0) {
      index = phoneBucketBounds.length;
    }
    final bucket = buckets[index];
    bucket.valueSats += utxo.valueSats;
    bucket.count += 1;
    bucket.outpoints.add(utxo.output);
  }
  return buckets;
}

/// The phone form of the UTXO distribution: one bar per bucket, with the coin count above it.
class UTXOPhoneBars extends StatelessWidget {
  final List<UnspentOutput> utxos;
  final void Function(UTXOBucket bucket, Offset position)? onBucketContextMenu;

  const UTXOPhoneBars({super.key, required this.utxos, this.onBucketContextMenu});

  static const double barWidth = 38;
  static const double maxBarHeight = 100;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final buckets = phoneUtxoBuckets(utxos);
    final most = buckets.fold<int>(0, (most, b) => b.count > most ? b.count : most);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < buckets.length; i++)
            Expanded(
              child: GestureDetector(
                key: ValueKey('utxo_bar_$i'),
                behavior: HitTestBehavior.opaque,
                onLongPressStart: buckets[i].count == 0
                    ? null
                    : (details) => onBucketContextMenu?.call(buckets[i], details.globalPosition),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (buckets[i].count > 0) ...[
                      SailText.primary12('${buckets[i].count}'),
                      const SizedBox(height: SailStyleValues.padding04),
                    ],
                    Container(
                      width: barWidth,
                      height: buckets[i].count == 0 ? 1 : maxBarHeight * buckets[i].count / most,
                      color: buckets[i].count == 0 ? theme.colors.divider : theme.colors.orange,
                    ),
                    const SizedBox(height: SailStyleValues.padding08),
                    SailText.secondary12(buckets[i].label),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
