import 'package:coinshift/providers/analytics_provider.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

/// Widget for monitoring liquidity and chain health across parent chains.
class LiquidityMonitorWidget extends StatelessWidget {
  const LiquidityMonitorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LiquidityMonitorViewModel>.reactive(
      viewModelBuilder: () => LiquidityMonitorViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Liquidity Monitor',
          subtitle: 'Chain health and swap capacity',
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Overall health summary
              _OverallHealthSummary(model: model),

              // Chain-specific health cards
              ...model.chainHealth.entries
                  .where((e) => e.value.activeSwaps > 0 || e.value.pendingVolume > 0)
                  .map((entry) => _ChainHealthCard(
                        chain: entry.key,
                        health: entry.value,
                      )),

              // Active swaps summary
              if (model.hasActiveSwaps) _ActiveSwapsSummary(model: model),
            ],
          ),
        );
      },
    );
  }
}

class _OverallHealthSummary extends StatelessWidget {
  final LiquidityMonitorViewModel model;

  const _OverallHealthSummary({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();
    final allHealthy = model.chainHealth.values.every((h) => h.isHealthy);

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        decoration: BoxDecoration(
          color: allHealthy
              ? theme.colors.success.withValues(alpha: 0.1)
              : theme.colors.orange.withValues(alpha: 0.1),
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: allHealthy ? theme.colors.success : theme.colors.orange,
          ),
        ),
        child: SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            Icon(
              allHealthy ? Icons.check_circle : Icons.warning,
              color: allHealthy ? theme.colors.success : theme.colors.orange,
              size: 32,
            ),
            Expanded(
              child: SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary15(
                    allHealthy ? 'All Systems Healthy' : 'Attention Required',
                    bold: true,
                  ),
                  SailText.secondary13(
                    'Active swaps: ${model.totalActiveSwaps} | '
                    'Pending volume: ${formatter.formatSats(model.totalPendingVolume)}',
                  ),
                ],
              ),
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
      ),
    );
  }
}

class _ChainHealthCard extends StatelessWidget {
  final ParentChainType chain;
  final ChainHealth health;

  const _ChainHealthCard({
    required this.chain,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: health.isHealthy ? theme.colors.divider : theme.colors.orange,
            width: health.isHealthy ? 1 : 2,
          ),
        ),
        child: SailColumn(
          spacing: SailStyleValues.padding12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with chain name and status
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _ChainIcon(chain: chain),
                    SailText.primary15(chain.value, bold: true),
                  ],
                ),
                _HealthIndicator(isHealthy: health.isHealthy),
              ],
            ),

            // Metrics row
            SailRow(
              spacing: SailStyleValues.padding16,
              children: [
                _MetricDisplay(
                  label: 'Active Swaps',
                  value: health.activeSwaps.toString(),
                  color: health.activeSwaps > 5
                      ? theme.colors.orange
                      : theme.colors.text,
                ),
                _MetricDisplay(
                  label: 'Pending Volume',
                  value: formatter.formatSats(health.pendingVolume),
                  color: theme.colors.info,
                ),
                _MetricDisplay(
                  label: 'Success Rate',
                  value: '${(health.successRate * 100).toStringAsFixed(1)}%',
                  color: health.successRate >= 0.8
                      ? theme.colors.success
                      : theme.colors.orange,
                ),
              ],
            ),

            // Progress bar for success rate
            _SuccessRateBar(rate: health.successRate),
          ],
        ),
      ),
    );
  }
}

class _ChainIcon extends StatelessWidget {
  final ParentChainType chain;

  const _ChainIcon({required this.chain});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    IconData icon;
    switch (chain) {
      case ParentChainType.btc:
        icon = Icons.currency_bitcoin;
      case ParentChainType.bch:
        icon = Icons.currency_bitcoin;
      case ParentChainType.ltc:
        icon = Icons.attach_money;
      case ParentChainType.signet:
        icon = Icons.science;
      case ParentChainType.regtest:
        icon = Icons.bug_report;
    }

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding04),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Icon(icon, size: 20, color: theme.colors.text),
    );
  }
}

class _HealthIndicator extends StatelessWidget {
  final bool isHealthy;

  const _HealthIndicator({required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final color = isHealthy ? theme.colors.success : theme.colors.orange;

    return SailRow(
      spacing: SailStyleValues.padding04,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SailText.secondary12(
          isHealthy ? 'Healthy' : 'Attention',
          color: color,
        ),
      ],
    );
  }
}

class _MetricDisplay extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricDisplay({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        SailText.primary13(value, bold: true, color: color),
      ],
    );
  }
}

class _SuccessRateBar extends StatelessWidget {
  final double rate;

  const _SuccessRateBar({required this.rate});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final clampedRate = rate.clamp(0.0, 1.0);

    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12('Success Rate'),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: theme.colors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedRate,
            child: Container(
              decoration: BoxDecoration(
                color: clampedRate >= 0.8
                    ? theme.colors.success
                    : clampedRate >= 0.5
                        ? theme.colors.orange
                        : theme.colors.error,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveSwapsSummary extends StatelessWidget {
  final LiquidityMonitorViewModel model;

  const _ActiveSwapsSummary({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13('Active Swaps by State'),
          SailRow(
            spacing: SailStyleValues.padding16,
            children: [
              _SwapStateCount(
                label: 'Pending',
                count: model.pendingCount,
                color: theme.colors.orange,
              ),
              _SwapStateCount(
                label: 'Waiting',
                count: model.waitingCount,
                color: theme.colors.info,
              ),
              _SwapStateCount(
                label: 'Claimable',
                count: model.claimableCount,
                color: theme.colors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwapStateCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SwapStateCount({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding08,
            vertical: SailStyleValues.padding04,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SailText.primary13(
            count.toString(),
            bold: true,
            color: color,
          ),
        ),
        SailText.secondary12(label),
      ],
    );
  }
}

class LiquidityMonitorViewModel extends BaseViewModel {
  AnalyticsProvider get _analyticsProvider => GetIt.I.get<AnalyticsProvider>();
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();

  Map<ParentChainType, ChainHealth> get chainHealth => _analyticsProvider.chainHealth;
  bool get isLoading => _analyticsProvider.isLoading;

  int get totalActiveSwaps => chainHealth.values.fold(0, (sum, h) => sum + h.activeSwaps);
  int get totalPendingVolume => chainHealth.values.fold(0, (sum, h) => sum + h.pendingVolume);
  bool get hasActiveSwaps => totalActiveSwaps > 0;

  int get pendingCount => _swapProvider.pendingSwaps.length;
  int get waitingCount => _swapProvider.waitingConfirmationsSwaps.length;
  int get claimableCount => _swapProvider.claimableSwaps.length;

  LiquidityMonitorViewModel() {
    _analyticsProvider.addListener(notifyListeners);
    _swapProvider.addListener(notifyListeners);
  }

  Future<void> refresh() async {
    await _analyticsProvider.refresh();
  }

  @override
  void dispose() {
    _analyticsProvider.removeListener(notifyListeners);
    _swapProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
