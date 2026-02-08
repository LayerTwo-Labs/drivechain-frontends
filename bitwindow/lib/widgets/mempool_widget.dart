import 'dart:math';

import 'package:bitwindow/providers/mempool_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class MempoolWidget extends StatelessWidget {
  const MempoolWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GetIt.I.get<MempoolProvider>(),
      builder: (context, child) {
        final provider = GetIt.I.get<MempoolProvider>();
        final stats = provider.stats;

        return SailCard(
          title: 'Mempool',
          subtitle: provider.error != null ? 'Error: ${provider.error}' : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use column layout for narrow widgets, row for wide
              final isWide = constraints.maxWidth > 600;

              return SailColumn(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MempoolStatsRow(stats: stats),
                  if (isWide)
                    SizedBox(
                      height: 200,
                      child: SailRow(
                        spacing: SailStyleValues.padding16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: FeeDistributionChart(buckets: stats.feeBuckets),
                          ),
                          Expanded(
                            child: FeeEstimatesPanel(estimates: stats.feeEstimates),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 150,
                      child: FeeDistributionChart(buckets: stats.feeBuckets),
                    ),
                    SizedBox(
                      height: 150,
                      child: FeeEstimatesPanel(estimates: stats.feeEstimates),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class MempoolStatsRow extends StatelessWidget {
  final MempoolStats stats;

  const MempoolStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Wrap(
      spacing: SailStyleValues.padding16,
      runSpacing: SailStyleValues.padding08,
      children: [
        _StatCard(
          label: 'Transactions',
          value: stats.txCount.toString(),
          icon: SailSVGAsset.iconTransactions,
          theme: theme,
        ),
        _StatCard(
          label: 'Size',
          value: '${stats.totalVsizeMB.toStringAsFixed(2)} MB',
          icon: SailSVGAsset.blocks,
          theme: theme,
        ),
        _StatCard(
          label: 'Median Fee',
          value: '${stats.medianFeeRate.toStringAsFixed(1)} sat/vB',
          icon: SailSVGAsset.dollarSign,
          theme: theme,
        ),
        _StatCard(
          label: 'Total Fees',
          value: '${(stats.totalFees / 100000000).toStringAsFixed(4)} BTC',
          icon: SailSVGAsset.iconWallet,
          theme: theme,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final SailSVGAsset icon;
  final SailThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailSVG.fromAsset(icon, color: theme.colors.textTertiary, width: 16),
          SailColumn(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SailText.secondary12(label),
              SailText.primary13(value),
            ],
          ),
        ],
      ),
    );
  }
}

class FeeDistributionChart extends StatelessWidget {
  final List<FeeBucket> buckets;

  const FeeDistributionChart({super.key, required this.buckets});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (buckets.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: Center(
          child: SailText.secondary12('No mempool data'),
        ),
      );
    }

    // Find max for scaling
    final maxVsize = buckets.map((b) => b.totalVsize).reduce(max);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12('Fee Distribution (sat/vB)'),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buckets.map((bucket) {
                final heightRatio = maxVsize > 0 ? bucket.totalVsize / maxVsize : 0.0;
                final color = _getColorForFeeRate(bucket.minFeeRate, theme);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message:
                              '${bucket.txCount} txs\n${(bucket.totalVsize / 1000).toStringAsFixed(1)} kB\n${bucket.totalFees.toStringAsFixed(0)} sats',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: max(4, heightRatio * 100),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SailText.secondary12(
                          bucket.label,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForFeeRate(double feeRate, SailThemeData theme) {
    // Color gradient from green (low fee) to red (high fee)
    if (feeRate < 2) return theme.colors.success;
    if (feeRate < 5) return theme.colors.success.withValues(alpha: 0.7);
    if (feeRate < 10) return theme.colors.orangeLight;
    if (feeRate < 20) return theme.colors.orange;
    if (feeRate < 50) return theme.colors.error.withValues(alpha: 0.7);
    return theme.colors.error;
  }
}

class FeeEstimatesPanel extends StatelessWidget {
  final List<FeeEstimate> estimates;

  const FeeEstimatesPanel({super.key, required this.estimates});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12('Fee Estimates'),
          const SizedBox(height: 8),
          Expanded(
            child: estimates.isEmpty
                ? Center(child: SailText.secondary12('No estimates available'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: estimates.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final estimate = estimates[index];
                      return _FeeEstimateRow(estimate: estimate, theme: theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FeeEstimateRow extends StatelessWidget {
  final FeeEstimate estimate;
  final SailThemeData theme;

  const _FeeEstimateRow({
    required this.estimate,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SailText.secondary12(
            estimate.urgency,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SailText.primary12(
          '${estimate.feeRate.toStringAsFixed(1)} sat/vB',
        ),
      ],
    );
  }
}
