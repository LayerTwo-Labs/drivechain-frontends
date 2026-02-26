import 'package:auto_route/auto_route.dart';
import 'package:coinshift/providers/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SwapAnalyticsPage extends StatelessWidget {
  const SwapAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SwapAnalyticsViewModel>.reactive(
      viewModelBuilder: () => SwapAnalyticsViewModel(),
      builder: (context, model, child) {
        return QtPage(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Header with time range selector
              _AnalyticsHeader(model: model),

              // Stats cards row
              _StatsCardsRow(model: model),

              // Main content
              Expanded(
                child: SailRow(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Chain breakdown
                    Expanded(
                      flex: 1,
                      child: _ChainBreakdownCard(model: model),
                    ),

                    // Right side: Swaps needing attention
                    Expanded(
                      flex: 2,
                      child: _SwapsNeedingAttentionCard(model: model),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  final SwapAnalyticsViewModel model;

  const _AnalyticsHeader({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailRow(
        spacing: SailStyleValues.padding16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.primary20('Swap Analytics', bold: true),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.secondary13('Time Range:'),
              SailDropdownButton<AnalyticsTimeRange>(
                value: model.selectedTimeRange,
                items: AnalyticsTimeRange.values
                    .map(
                      (range) => SailDropdownItem<AnalyticsTimeRange>(
                        value: range,
                        label: range.displayName,
                      ),
                    )
                    .toList(),
                onChanged: (range) {
                  if (range != null) {
                    model.setTimeRange(range);
                  }
                },
              ),
              SailButton(
                label: 'Refresh',
                small: true,
                variant: ButtonVariant.secondary,
                loading: model.isLoading,
                onPressed: () async => await model.refresh(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCardsRow extends StatelessWidget {
  final SwapAnalyticsViewModel model;

  const _StatsCardsRow({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();
    final stats = model.statistics;

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailRow(
        spacing: SailStyleValues.padding16,
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Swaps',
              value: stats.totalSwaps.toString(),
              color: theme.colors.text,
            ),
          ),
          Expanded(
            child: _StatCard(
              title: 'Completed',
              value: stats.completedSwaps.toString(),
              subtitle: '${(stats.successRate * 100).toStringAsFixed(1)}% success',
              color: theme.colors.success,
            ),
          ),
          Expanded(
            child: _StatCard(
              title: 'Pending',
              value: stats.pendingSwaps.toString(),
              color: theme.colors.orange,
            ),
          ),
          Expanded(
            child: _StatCard(
              title: 'Volume (L2)',
              value: formatter.formatSats(stats.l2AmountTotal),
              color: theme.colors.info,
            ),
          ),
          Expanded(
            child: _StatCard(
              title: 'Volume (L1)',
              value: formatter.formatSats(stats.l1AmountTotal),
              color: theme.colors.info,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailColumn(
        spacing: SailStyleValues.padding04,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12(title),
          SailText.primary24(value, bold: true, color: color),
          if (subtitle != null) SailText.secondary12(subtitle!),
        ],
      ),
    );
  }
}

class _ChainBreakdownCard extends StatelessWidget {
  final SwapAnalyticsViewModel model;

  const _ChainBreakdownCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final chainHealth = model.chainHealth;

    return SailCard(
      title: 'Chain Breakdown',
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          if (chainHealth.isEmpty)
            SailText.secondary13('No swap data available')
          else
            ...chainHealth.entries.where((e) => e.value.activeSwaps > 0 || model.statistics.swapsByChain[e.key] != null).map(
              (entry) {
                final chain = entry.key;
                final health = entry.value;
                final swapCount = model.statistics.swapsByChain[chain] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(SailStyleValues.padding12),
                  decoration: BoxDecoration(
                    color: theme.colors.backgroundSecondary,
                    borderRadius: SailStyleValues.borderRadius,
                    border: Border.all(
                      color: health.isHealthy ? theme.colors.divider : theme.colors.orange,
                    ),
                  ),
                  child: SailColumn(
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.primary15(chain.value, bold: true),
                          _HealthBadge(isHealthy: health.isHealthy),
                        ],
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding16,
                        children: [
                          _ChainStat(label: 'Total', value: swapCount.toString()),
                          _ChainStat(label: 'Active', value: health.activeSwaps.toString()),
                          _ChainStat(
                            label: 'Success',
                            value: '${(health.successRate * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final bool isHealthy;

  const _HealthBadge({required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final color = isHealthy ? theme.colors.success : theme.colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding08,
        vertical: SailStyleValues.padding04,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: color),
      ),
      child: SailText.secondary12(
        isHealthy ? 'Healthy' : 'Attention',
        color: color,
      ),
    );
  }
}

class _ChainStat extends StatelessWidget {
  final String label;
  final String value;

  const _ChainStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        SailText.primary13(value, bold: true),
      ],
    );
  }
}

class _SwapsNeedingAttentionCard extends StatelessWidget {
  final SwapAnalyticsViewModel model;

  const _SwapsNeedingAttentionCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final swaps = model.swapsNeedingAttention;
    final formatter = GetIt.I<FormatterProvider>();

    return SailCard(
      title: 'Swaps Needing Attention',
      subtitle: swaps.isEmpty ? null : '${swaps.length} swap(s) may need your attention',
      bottomPadding: false,
      child: swaps.isEmpty
          ? Center(
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: theme.colors.success, size: 48),
                  SailText.primary15('All swaps are healthy'),
                  SailText.secondary13('No swaps require attention at this time'),
                ],
              ),
            )
          : ListenableBuilder(
              listenable: formatter,
              builder: (context, child) => ListView.separated(
                itemCount: swaps.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final swap = swaps[index];
                  return _SwapAttentionRow(swap: swap, formatter: formatter);
                },
              ),
            ),
    );
  }
}

class _SwapAttentionRow extends StatelessWidget {
  final CoinShiftSwap swap;
  final FormatterProvider formatter;

  const _SwapAttentionRow({required this.swap, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    String issue;
    Color issueColor;

    if (swap.state.isPending) {
      issue = 'Pending - waiting for L1 payment';
      issueColor = theme.colors.orange;
    } else if (swap.state.isWaitingConfirmations) {
      final current = swap.state.currentConfirmations ?? 0;
      final required = swap.state.requiredConfirmations ?? 1;
      issue = 'Waiting: $current/$required confirmations';
      issueColor = theme.colors.info;
    } else {
      issue = swap.state.state;
      issueColor = theme.colors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      child: SailRow(
        spacing: SailStyleValues.padding16,
        children: [
          Icon(Icons.warning_amber, color: issueColor, size: 20),
          Expanded(
            child: SailColumn(
              spacing: SailStyleValues.padding04,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13(
                  'Swap ${swap.idHex.substring(0, 12)}...',
                  monospace: true,
                ),
                SailText.secondary12(issue, color: issueColor),
              ],
            ),
          ),
          SailText.primary13(
            formatter.formatSats(swap.l2Amount),
            monospace: true,
          ),
          SailText.secondary12(swap.parentChain.value),
        ],
      ),
    );
  }
}

class SwapAnalyticsViewModel extends BaseViewModel {
  AnalyticsProvider get _analyticsProvider => GetIt.I.get<AnalyticsProvider>();

  AnalyticsTimeRange get selectedTimeRange => _analyticsProvider.selectedTimeRange;
  SwapStatistics get statistics => _analyticsProvider.statistics;
  Map<ParentChainType, ChainHealth> get chainHealth => _analyticsProvider.chainHealth;
  List<CoinShiftSwap> get swapsNeedingAttention => _analyticsProvider.swapsNeedingAttention;
  bool get isLoading => _analyticsProvider.isLoading;

  SwapAnalyticsViewModel() {
    _analyticsProvider.addListener(notifyListeners);
  }

  void setTimeRange(AnalyticsTimeRange range) {
    _analyticsProvider.setTimeRange(range);
  }

  Future<void> refresh() async {
    await _analyticsProvider.refresh();
  }

  @override
  void dispose() {
    _analyticsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
