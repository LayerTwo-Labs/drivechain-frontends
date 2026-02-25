import 'dart:math';

import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

/// Widget showing AMM pool analytics with impermanent loss calculator
class AmmAnalyticsWidget extends StatelessWidget {
  const AmmAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AmmAnalyticsViewModel>.reactive(
      viewModelBuilder: () => AmmAnalyticsViewModel(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);

        return SailColumn(
          spacing: SailStyleValues.padding16,
          children: [
            // Header stats
            SailRow(
              spacing: SailStyleValues.padding16,
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Active Pools',
                    value: model.pools.length.toString(),
                    icon: SailSVGAsset.iconArrow,
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    title: 'Total TVL',
                    value: model.formattedTotalTvl,
                    icon: SailSVGAsset.iconCoins,
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    title: 'Swap Fee',
                    value: '0.3%',
                    icon: SailSVGAsset.iconInfo,
                  ),
                ),
              ],
            ),

            // Main content row
            SailRow(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pool list
                Expanded(
                  flex: 3,
                  child: SailCard(
                    title: 'Liquidity Pools',
                    subtitle: 'Active AMM pools on the network',
                    child: model.isLoading
                        ? const SizedBox(
                            height: 300,
                            child: Center(child: SailCircularProgressIndicator()),
                          )
                        : model.pools.isEmpty
                        ? SizedBox(
                            height: 300,
                            child: Center(
                              child: SailColumn(
                                spacing: SailStyleValues.padding16,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SailSVG.icon(SailSVGAsset.iconArrow, width: 48),
                                  const SizedBox(height: 8),
                                  SailText.secondary13('No active pools'),
                                  SailText.secondary12('Create a pool by providing liquidity'),
                                  SailButton(
                                    label: 'Add Liquidity',
                                    onPressed: () async {
                                      await GetIt.I.get<AppRouter>().navigate(const AmmTabRoute());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              // Table header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SailStyleValues.padding12,
                                  vertical: SailStyleValues.padding08,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colors.backgroundSecondary,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: SailText.secondary12('Pool'),
                                    ),
                                    Expanded(
                                      child: SailText.secondary12('Reserve 0', textAlign: TextAlign.right),
                                    ),
                                    Expanded(
                                      child: SailText.secondary12('Reserve 1', textAlign: TextAlign.right),
                                    ),
                                    Expanded(
                                      child: SailText.secondary12('LP Tokens', textAlign: TextAlign.right),
                                    ),
                                    Expanded(
                                      child: SailText.secondary12('Price', textAlign: TextAlign.right),
                                    ),
                                  ],
                                ),
                              ),
                              // Pool rows
                              ...model.pools.map(
                                (pool) => _PoolRow(
                                  pool: pool,
                                  onCopyPairName: () => model.copyToClipboard(pool.pairName, context),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // IL Calculator
                Expanded(
                  flex: 2,
                  child: SailCard(
                    title: 'Impermanent Loss Calculator',
                    subtitle: 'Estimate IL for price changes',
                    child: SailColumn(
                      spacing: SailStyleValues.padding16,
                      children: [
                        // Price change input
                        SailColumn(
                          spacing: SailStyleValues.padding08,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.secondary12('Price Change Multiplier'),
                            SailTextField(
                              hintText: 'e.g., 2 for 2x price increase',
                              controller: model.priceChangeController,
                              suffix: 'x',
                            ),
                          ],
                        ),

                        // Quick buttons
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickButton(
                              label: '0.5x',
                              onTap: () => model.setPriceChange('0.5'),
                            ),
                            _QuickButton(
                              label: '0.75x',
                              onTap: () => model.setPriceChange('0.75'),
                            ),
                            _QuickButton(
                              label: '1.5x',
                              onTap: () => model.setPriceChange('1.5'),
                            ),
                            _QuickButton(
                              label: '2x',
                              onTap: () => model.setPriceChange('2'),
                            ),
                            _QuickButton(
                              label: '3x',
                              onTap: () => model.setPriceChange('3'),
                            ),
                            _QuickButton(
                              label: '5x',
                              onTap: () => model.setPriceChange('5'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Result
                        Container(
                          padding: const EdgeInsets.all(SailStyleValues.padding16),
                          decoration: BoxDecoration(
                            color: theme.colors.backgroundSecondary,
                            borderRadius: SailStyleValues.borderRadius,
                          ),
                          child: SailColumn(
                            spacing: SailStyleValues.padding12,
                            children: [
                              SailRow(
                                spacing: SailStyleValues.padding08,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SailText.secondary13('Impermanent Loss'),
                                  SailText.primary20(
                                    model.impermanentLoss != null
                                        ? '${model.impermanentLoss!.toStringAsFixed(2)}%'
                                        : '—',
                                    bold: true,
                                    color: model.impermanentLoss != null && model.impermanentLoss! > 5
                                        ? theme.colors.error
                                        : null,
                                  ),
                                ],
                              ),
                              if (model.impermanentLoss != null)
                                SailText.secondary12(
                                  model.ilExplanation,
                                ),
                            ],
                          ),
                        ),

                        // IL explanation
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(SailStyleValues.padding12),
                          decoration: BoxDecoration(
                            color: theme.colors.info.withValues(alpha: 0.1),
                            borderRadius: SailStyleValues.borderRadius,
                            border: Border.all(color: theme.colors.info.withValues(alpha: 0.3)),
                          ),
                          child: SailRow(
                            spacing: SailStyleValues.padding08,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailSVG.icon(SailSVGAsset.iconInfo, width: 16, color: theme.colors.info),
                              Expanded(
                                child: SailText.secondary12(
                                  'Impermanent loss occurs when the price ratio of pooled assets changes. '
                                  'The loss is "impermanent" because it can be recovered if prices return to original ratio.',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Formula
                        const SizedBox(height: 8),
                        SailText.secondary12(
                          'Formula: IL = 2√r / (1+r) - 1, where r = price ratio',
                          monospace: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Pool depth visualization
            if (model.pools.isNotEmpty)
              SailCard(
                title: 'Pool Depth Comparison',
                child: SizedBox(
                  height: 150,
                  child: SailRow(
                    spacing: SailStyleValues.padding16,
                    children: model.pools.map((pool) => _PoolDepthBar(pool: pool, maxTvl: model.maxTvl)).toList(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final SailSVGAsset icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailRow(
        spacing: SailStyleValues.padding12,
        children: [
          SailSVG.icon(icon, width: 24),
          SailColumn(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary12(title),
              SailText.primary20(value, bold: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _PoolRow extends StatelessWidget {
  final PoolAnalytics pool;
  final VoidCallback onCopyPairName;

  const _PoolRow({
    required this.pool,
    required this.onCopyPairName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Pool pair
          Expanded(
            flex: 2,
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailColumn(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13(pool.pairName, bold: true),
                      SailText.secondary12(
                        'TVL: ${_formatSats(pool.tvl)}',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: SailSVG.icon(SailSVGAsset.iconCopy, width: 12),
                  onPressed: onCopyPairName,
                  tooltip: 'Copy pool pair',
                  iconSize: 12,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ],
            ),
          ),

          // Reserve 0
          Expanded(
            child: SailText.primary13(
              _formatAmount(pool.reserve0),
              textAlign: TextAlign.right,
              monospace: true,
            ),
          ),

          // Reserve 1
          Expanded(
            child: SailText.primary13(
              _formatAmount(pool.reserve1),
              textAlign: TextAlign.right,
              monospace: true,
            ),
          ),

          // LP Tokens
          Expanded(
            child: SailText.primary13(
              _formatAmount(pool.outstandingLpTokens),
              textAlign: TextAlign.right,
              monospace: true,
            ),
          ),

          // Price
          Expanded(
            child: SailText.primary13(
              pool.priceRatio > 0 ? pool.priceRatio.toStringAsFixed(4) : '—',
              textAlign: TextAlign.right,
              monospace: true,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSats(int sats) {
    if (sats >= 100000000) {
      return '${(sats / 100000000).toStringAsFixed(2)} BTC';
    } else if (sats >= 1000000) {
      return '${(sats / 1000000).toStringAsFixed(2)}M sats';
    } else if (sats >= 1000) {
      return '${(sats / 1000).toStringAsFixed(1)}k sats';
    }
    return '$sats sats';
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toString();
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(color: theme.colors.divider),
        ),
        child: SailText.primary12(label),
      ),
    );
  }
}

class _PoolDepthBar extends StatelessWidget {
  final PoolAnalytics pool;
  final int maxTvl;

  const _PoolDepthBar({required this.pool, required this.maxTvl});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final heightPercent = maxTvl > 0 ? pool.tvl / maxTvl : 0.0;

    return Expanded(
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightPercent,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.colors.primary,
                        theme.colors.primary.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
          SailText.secondary12(
            pool.pairName,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AmmAnalyticsViewModel extends BaseViewModel {
  final AssetAnalyticsProvider analyticsProvider = GetIt.I.get<AssetAnalyticsProvider>();
  final BitAssetsProvider bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();

  final TextEditingController priceChangeController = TextEditingController();

  double? impermanentLoss;

  AmmAnalyticsViewModel() {
    analyticsProvider.addListener(notifyListeners);
    bitAssetsProvider.addListener(notifyListeners);
    priceChangeController.addListener(_calculateIL);
  }

  bool get isLoading => analyticsProvider.isLoadingPools;

  List<PoolAnalytics> get pools => analyticsProvider.pools;

  int get maxTvl {
    if (pools.isEmpty) return 1;
    return pools.map((p) => p.tvl).reduce(max);
  }

  String get formattedTotalTvl {
    final total = pools.fold<int>(0, (sum, pool) => sum + pool.tvl);
    if (total >= 100000000) {
      return '${(total / 100000000).toStringAsFixed(2)} BTC';
    } else if (total >= 1000000) {
      return '${(total / 1000000).toStringAsFixed(2)}M sats';
    } else if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(1)}k sats';
    }
    return '$total sats';
  }

  void setPriceChange(String value) {
    priceChangeController.text = value;
  }

  void _calculateIL() {
    final priceChange = double.tryParse(priceChangeController.text);
    if (priceChange == null || priceChange <= 0) {
      impermanentLoss = null;
    } else {
      impermanentLoss = PoolAnalytics.calculateImpermanentLoss(priceChange);
    }
    notifyListeners();
  }

  String get ilExplanation {
    if (impermanentLoss == null) return '';

    final priceChange = double.tryParse(priceChangeController.text);
    if (priceChange == null) return '';

    if (priceChange > 1) {
      return 'If the price increases ${priceChange}x, you would have ${impermanentLoss!.toStringAsFixed(2)}% less value than holding.';
    } else if (priceChange < 1) {
      final decrease = ((1 - priceChange) * 100).toStringAsFixed(0);
      return 'If the price decreases $decrease%, you would have ${impermanentLoss!.toStringAsFixed(2)}% less value than holding.';
    }
    return 'No impermanent loss at 1x (no price change).';
  }

  void copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    notificationProvider.add(
      title: 'Copied',
      content: 'Pool pair copied to clipboard',
      dialogType: DialogType.success,
    );
  }

  @override
  void dispose() {
    priceChangeController.removeListener(_calculateIL);
    priceChangeController.dispose();
    analyticsProvider.removeListener(notifyListeners);
    bitAssetsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
