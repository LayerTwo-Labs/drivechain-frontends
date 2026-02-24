import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/routing/router.dart';

class TradingPositionWidget extends StatelessWidget {
  final String? address;

  const TradingPositionWidget({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TradingPositionViewModel>.reactive(
      viewModelBuilder: () => TradingPositionViewModel(address: address),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);
        final formatter = GetIt.I<FormatterProvider>();

        return SailCard(
          title: 'Your Positions',
          bottomPadding: false,
          child: ListenableBuilder(
            listenable: formatter,
            builder: (context, _) {
              if (model.isLoading) {
                return SailSkeletonizer(
                  enabled: true,
                  description: 'Loading positions...',
                  child: SailText.primary15('Loading...'),
                );
              }

              if (model.holdings == null || model.holdings!.positions.isEmpty) {
                return SailColumn(
                  children: [
                    SailText.secondary15('No positions yet'),
                    const SizedBox(height: 8),
                    SailButton(
                      label: 'Browse Markets',
                      small: true,
                      onPressed: () async {
                        await GetIt.I.get<AppRouter>().push(const MarketExplorerRoute());
                      },
                    ),
                  ],
                );
              }

              final holdings = model.holdings!;

              return SailColumn(
                spacing: SailStyleValues.padding12,
                children: [
                  // Summary header
                  SailRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SailColumn(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.secondary12('Total Value'),
                          SailText.primary20(
                            formatter.formatBTC(holdings.totalValue),
                            bold: true,
                          ),
                        ],
                      ),
                      SailColumn(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SailText.secondary12('Unrealized P&L'),
                          SailRow(
                            spacing: SailStyleValues.padding04,
                            children: [
                              Icon(
                                holdings.hasProfits ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 16,
                                color: holdings.hasProfits ? theme.colors.success : theme.colors.error,
                              ),
                              SailText.primary15(
                                '${holdings.totalUnrealizedPnl >= 0 ? '+' : ''}${holdings.totalPnlPercent.toStringAsFixed(1)}%',
                                bold: true,
                                color: holdings.hasProfits ? theme.colors.success : theme.colors.error,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(),

                  // Positions list
                  SizedBox(
                    height: 200,
                    child: SailTable(
                      getRowId: (index) =>
                          '${holdings.positions[index].marketId}_${holdings.positions[index].outcomeIndex}',
                      headerBuilder: (context) => const [
                        SailTableHeaderCell(name: 'Market'),
                        SailTableHeaderCell(name: 'Outcome'),
                        SailTableHeaderCell(name: 'Shares'),
                        SailTableHeaderCell(name: 'Value'),
                        SailTableHeaderCell(name: 'P&L'),
                      ],
                      rowBuilder: (context, row, selected) {
                        final position = holdings.positions[row];
                        return [
                          SailTableCell(
                            value: position.marketId.substring(0, 8),
                            monospace: true,
                          ),
                          SailTableCell(value: position.outcomeName),
                          SailTableCell(
                            value: position.shares.toString(),
                            monospace: true,
                          ),
                          SailTableCell(
                            value: formatter.formatBTC(position.currentValue),
                            monospace: true,
                          ),
                          SailTableCell(
                            value: position.pnlDisplay,
                            child: SailRow(
                              spacing: SailStyleValues.padding04,
                              children: [
                                Icon(
                                  position.isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 12,
                                  color: position.isProfit ? theme.colors.success : theme.colors.error,
                                ),
                                SailText.secondary12(
                                  position.pnlDisplay,
                                  color: position.isProfit ? theme.colors.success : theme.colors.error,
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                      rowCount: holdings.positions.length,
                      emptyPlaceholder: 'No positions',
                      drawGrid: true,
                      onDoubleTap: (marketId) {
                        GetIt.I.get<AppRouter>().push(MarketDetailRoute(marketId: marketId));
                      },
                    ),
                  ),

                  // Footer
                  SailRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SailText.secondary12('${holdings.activeMarkets} active markets'),
                      SailButton(
                        label: 'Refresh',
                        small: true,
                        onPressed: () async => model.refresh(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class TradingPositionViewModel extends BaseViewModel {
  final String? address;
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();

  UserHoldings? get holdings => _marketProvider.userPositions;
  bool isLoading = false;

  TradingPositionViewModel({this.address});

  void init() {
    _marketProvider.addListener(_onProviderChange);
    if (address != null) {
      loadPositions();
    }
  }

  void _onProviderChange() {
    notifyListeners();
  }

  Future<void> loadPositions() async {
    if (address == null) return;

    isLoading = true;
    notifyListeners();

    await _marketProvider.loadUserPositions(address!);

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadPositions();
  }

  @override
  void dispose() {
    _marketProvider.removeListener(_onProviderChange);
    super.dispose();
  }
}

/// Compact positions summary widget for homepage
class PositionsSummaryWidget extends StatelessWidget {
  final String? address;

  const PositionsSummaryWidget({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TradingPositionViewModel>.reactive(
      viewModelBuilder: () => TradingPositionViewModel(address: address),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);
        final formatter = GetIt.I<FormatterProvider>();

        return ListenableBuilder(
          listenable: formatter,
          builder: (context, _) => SailCard(
            title: 'Positions Summary',
            child: model.isLoading
                ? SailSkeletonizer(
                    enabled: true,
                    description: 'Loading...',
                    child: SailText.primary15('Loading...'),
                  )
                : model.holdings == null
                ? SailText.secondary15('No positions')
                : SailColumn(
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.secondary13('Active Markets'),
                          SailText.primary15(model.holdings!.activeMarkets.toString(), bold: true),
                        ],
                      ),
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.secondary13('Total Value'),
                          SailText.primary15(
                            formatter.formatBTC(model.holdings!.totalValue),
                            bold: true,
                          ),
                        ],
                      ),
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.secondary13('Unrealized P&L'),
                          SailText.primary15(
                            '${model.holdings!.totalUnrealizedPnl >= 0 ? '+' : ''}${model.holdings!.totalPnlPercent.toStringAsFixed(1)}%',
                            bold: true,
                            color: model.holdings!.hasProfits ? theme.colors.success : theme.colors.error,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
