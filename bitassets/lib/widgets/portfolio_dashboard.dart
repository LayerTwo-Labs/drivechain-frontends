import 'dart:math';

import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/routing/router.dart';
import 'package:bitassets/widgets/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

/// Dashboard widget showing portfolio holdings breakdown
class PortfolioDashboard extends StatelessWidget {
  const PortfolioDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PortfolioDashboardViewModel>.reactive(
      viewModelBuilder: () => PortfolioDashboardViewModel(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);

        return SailColumn(
          spacing: SailStyleValues.padding16,
          children: [
            // Summary cards row
            SailRow(
              spacing: SailStyleValues.padding16,
              children: [
                // BTC Balance card
                Expanded(
                  child: _SummaryCard(
                    title: 'BTC Balance',
                    value: model.formattedBtcBalance,
                    subtitle: model.pendingBtcBalance > 0 ? '+${model.formattedPendingBtc} pending' : null,
                    icon: SailSVGAsset.iconCoins,
                    isLoading: model.isLoading,
                  ),
                ),
                // BitAsset holdings count
                Expanded(
                  child: _SummaryCard(
                    title: 'BitAsset Types',
                    value: model.bitAssetTypesHeld.toString(),
                    subtitle: 'unique assets held',
                    icon: SailSVGAsset.iconCoins,
                    isLoading: model.isLoading,
                  ),
                ),
                // Total holdings
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Holdings',
                    value: model.totalHoldingsCount.toString(),
                    subtitle: 'positions',
                    icon: SailSVGAsset.iconWallet,
                    isLoading: model.isLoading,
                  ),
                ),
              ],
            ),

            // Transaction history
            const TransactionHistoryCard(maxItems: 5),

            // Allocation breakdown
            SailRow(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Allocation chart
                Expanded(
                  flex: 1,
                  child: SailCard(
                    title: 'Allocation',
                    child: model.isLoading
                        ? const SizedBox(
                            height: 200,
                            child: Center(child: SailCircularProgressIndicator()),
                          )
                        : model.holdings.isEmpty
                        ? SizedBox(
                            height: 200,
                            child: Center(
                              child: SailText.secondary13('No holdings yet'),
                            ),
                          )
                        : SizedBox(
                            height: 200,
                            child: _AllocationChart(holdings: model.holdings),
                          ),
                  ),
                ),

                // Holdings table
                Expanded(
                  flex: 2,
                  child: SailCard(
                    title: 'Holdings',
                    child: model.isLoading
                        ? const SizedBox(
                            height: 200,
                            child: Center(child: SailCircularProgressIndicator()),
                          )
                        : model.holdings.isEmpty
                        ? SizedBox(
                            height: 200,
                            child: Center(
                              child: SailColumn(
                                spacing: SailStyleValues.padding16,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SailSVG.icon(SailSVGAsset.iconWallet, width: 48),
                                  SailText.secondary13('No holdings yet'),
                                  SailText.secondary12('Deposit BTC or acquire BitAssets to get started'),
                                  SailRow(
                                    spacing: SailStyleValues.padding08,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SailButton(
                                        label: 'Browse Auctions',
                                        onPressed: () async {
                                          await GetIt.I.get<AppRouter>().navigate(const AuctionBrowserTabRoute());
                                        },
                                      ),
                                      SailButton(
                                        label: 'Swap Assets',
                                        onPressed: () async {
                                          await GetIt.I.get<AppRouter>().navigate(const AmmTabRoute());
                                        },
                                      ),
                                    ],
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
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 2,
                                      child: SailText.secondary12('Asset'),
                                    ),
                                    Expanded(
                                      child: SailText.secondary12('Amount', textAlign: TextAlign.right),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: SailText.secondary12('Share', textAlign: TextAlign.right),
                                    ),
                                  ],
                                ),
                              ),
                              // Table rows
                              ...model.holdings.map(
                                (holding) => _HoldingRow(
                                  holding: holding,
                                  color: model.getColorForAsset(holding.assetId),
                                  assetName: model.getAssetName(holding.assetId),
                                  onCopyAssetId: () => model.copyToClipboard(holding.assetId, context),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final SailSVGAsset icon;
  final bool isLoading;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.isLoading,
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              borderRadius: SailStyleValues.borderRadius,
            ),
            child: Center(
              child: SailSVG.icon(icon, width: 24, color: theme.colors.primary),
            ),
          ),
          Expanded(
            child: SailColumn(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12(title),
                if (isLoading)
                  const SizedBox(
                    height: 24,
                    child: SailCircularProgressIndicator(),
                  )
                else
                  SailText.primary20(value, bold: true),
                if (subtitle != null && !isLoading) SailText.secondary12(subtitle!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationChart extends StatelessWidget {
  final List<AssetHolding> holdings;

  const _AllocationChart({required this.holdings});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight) - 20;
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _PieChartPainter(
                holdings: holdings,
                colors: _getColors(holdings.length, context),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getColors(int count, BuildContext context) {
    final theme = SailTheme.of(context);
    final baseColors = [
      theme.colors.primary,
      theme.colors.success,
      theme.colors.orange,
      theme.colors.error,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];

    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      colors.add(baseColors[i % baseColors.length]);
    }
    return colors;
  }
}

class _PieChartPainter extends CustomPainter {
  final List<AssetHolding> holdings;
  final List<Color> colors;

  _PieChartPainter({required this.holdings, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    double startAngle = -pi / 2;

    for (int i = 0; i < holdings.length; i++) {
      final holding = holdings[i];
      final sweepAngle = (holding.percentageOfPortfolio / 100) * 2 * pi;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw segment border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center hole for donut effect
    final holePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.transparent;

    canvas.drawCircle(center, radius * 0.5, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.holdings != holdings;
  }
}

class _HoldingRow extends StatelessWidget {
  final AssetHolding holding;
  final Color color;
  final String assetName;
  final VoidCallback onCopyAssetId;

  const _HoldingRow({
    required this.holding,
    required this.color,
    required this.assetName,
    required this.onCopyAssetId,
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
          // Color indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),

          // Asset name
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
                      SailText.primary13(assetName, bold: holding.isBtc),
                      if (!holding.isBtc)
                        SailText.secondary12(
                          '${holding.assetId.substring(0, 12)}...',
                          monospace: true,
                        ),
                    ],
                  ),
                ),
                if (!holding.isBtc)
                  IconButton(
                    icon: SailSVG.icon(SailSVGAsset.iconCopy, width: 12),
                    onPressed: onCopyAssetId,
                    tooltip: 'Copy asset ID',
                    iconSize: 12,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  ),
              ],
            ),
          ),

          // Amount
          Expanded(
            child: SailText.primary13(
              holding.isBtc ? _formatBtc(holding.amount) : _formatAmount(holding.amount),
              textAlign: TextAlign.right,
              monospace: true,
            ),
          ),

          // Percentage
          SizedBox(
            width: 80,
            child: SailText.primary13(
              '${holding.percentageOfPortfolio.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              bold: true,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBtc(int sats) {
    final btc = sats / 100000000;
    if (btc >= 1) {
      return '${btc.toStringAsFixed(4)} BTC';
    } else if (sats >= 1000) {
      return '${(sats / 1000).toStringAsFixed(2)}k sats';
    } else {
      return '$sats sats';
    }
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}k';
    }
    return amount.toString();
  }
}

class PortfolioDashboardViewModel extends BaseViewModel {
  final AssetAnalyticsProvider analyticsProvider = GetIt.I.get<AssetAnalyticsProvider>();
  final BitAssetsProvider bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();

  PortfolioDashboardViewModel() {
    analyticsProvider.addListener(notifyListeners);
    bitAssetsProvider.addListener(notifyListeners);
  }

  bool get isLoading => analyticsProvider.isLoadingHoldings;

  List<AssetHolding> get holdings => analyticsProvider.holdings;

  int get totalBtcBalance => analyticsProvider.totalBtcBalance;
  int get pendingBtcBalance => analyticsProvider.pendingBtcBalance;

  String get formattedBtcBalance {
    final btc = totalBtcBalance / 100000000;
    return '${btc.toStringAsFixed(8)} BTC';
  }

  String get formattedPendingBtc {
    final btc = pendingBtcBalance / 100000000;
    return '${btc.toStringAsFixed(8)} BTC';
  }

  int get bitAssetTypesHeld {
    return holdings.where((h) => !h.isBtc).length;
  }

  int get totalHoldingsCount => holdings.length;

  Color getColorForAsset(String assetId) {
    final index = holdings.indexWhere((h) => h.assetId == assetId);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  String getAssetName(String assetId) {
    if (assetId == 'btc') return 'BTC (Native)';

    // Try to find the asset in the provider
    final asset = bitAssetsProvider.entries.where((e) => e.hash == assetId).firstOrNull;
    return asset?.plaintextName ?? assetId.substring(0, 12);
  }

  void copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    notificationProvider.add(
      title: 'Copied',
      content: 'Asset ID copied to clipboard',
      dialogType: DialogType.success,
    );
  }

  @override
  void dispose() {
    analyticsProvider.removeListener(notifyListeners);
    bitAssetsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
