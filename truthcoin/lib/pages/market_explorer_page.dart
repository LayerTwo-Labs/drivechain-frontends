import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/routing/router.dart';

@RoutePage()
class MarketExplorerPage extends StatelessWidget {
  const MarketExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MarketExplorerViewModel>.reactive(
      viewModelBuilder: () => MarketExplorerViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return QtPage(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              _HeaderSection(model: model),
              _StatsSection(model: model),
              Expanded(child: _MarketListSection(model: model)),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final MarketExplorerViewModel model;

  const _HeaderSection({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        Expanded(
          flex: 2,
          child: SailTextField(
            controller: model.searchController,
            hintText: 'Search markets...',
            onChanged: model.onSearchChanged,
            prefixIcon: const Icon(Icons.search, size: 16),
          ),
        ),
        SizedBox(
          width: 150,
          child: SailDropdownButton<MarketState?>(
            value: model.stateFilter,
            items: [
              const SailDropdownItem<MarketState?>(
                value: null,
                label: 'All States',
              ),
              ...MarketState.values.map(
                (state) => SailDropdownItem<MarketState?>(
                  value: state,
                  label: state.displayName,
                ),
              ),
            ],
            onChanged: model.onStateFilterChanged,
          ),
        ),
        SizedBox(
          width: 150,
          child: SailDropdownButton<MarketSort>(
            value: model.sortBy,
            items: const [
              SailDropdownItem<MarketSort>(
                value: MarketSort.volume,
                label: 'By Volume',
              ),
              SailDropdownItem<MarketSort>(
                value: MarketSort.created,
                label: 'By Date',
              ),
              SailDropdownItem<MarketSort>(
                value: MarketSort.title,
                label: 'By Title',
              ),
            ],
            onChanged: (sort) {
              if (sort != null) model.onSortChanged(sort);
            },
          ),
        ),
        SailButton(
          label: '+ Create Market',
          onPressed: () async {
            await model.openCreateMarket(context);
          },
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final MarketExplorerViewModel model;

  const _StatsSection({required this.model});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, _) => SailRow(
        spacing: SailStyleValues.padding16,
        children: [
          _StatCard(
            label: 'Total Markets',
            value: model.totalMarkets.toString(),
          ),
          _StatCard(
            label: 'Active Markets',
            value: model.activeMarkets.toString(),
          ),
          _StatCard(
            label: 'Total Volume',
            value: formatter.formatBTC(model.totalVolumeBTC),
          ),
        ],
      ),
    );
  }
}

class _MarketListSection extends StatelessWidget {
  final MarketExplorerViewModel model;

  const _MarketListSection({required this.model});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    if (model.isLoading) {
      return Center(
        child: SailSkeletonizer(
          enabled: true,
          description: 'Loading markets...',
          child: SailText.primary15('Loading...'),
        ),
      );
    }

    if (model.marketError != null) {
      return Center(
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary15(model.marketError!),
            const SizedBox(height: 16),
            SailButton(
              label: 'Retry',
              onPressed: () async => model.loadMarkets(),
            ),
          ],
        ),
      );
    }

    if (model.markets.isEmpty) {
      return Center(
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.secondary15('No markets found'),
            const SizedBox(height: 16),
            SailButton(
              label: 'Create First Market',
              onPressed: () async => model.openCreateMarket(context),
            ),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, _) => SailCard(
        title: 'Markets (${model.markets.length})',
        bottomPadding: false,
        child: SailTable(
          getRowId: (index) => model.markets[index].marketId,
          headerBuilder: (context) => [
            SailTableHeaderCell(
              name: 'Title',
              onSort: () => model.onSortChanged(MarketSort.title),
            ),
            const SailTableHeaderCell(name: 'Outcomes'),
            SailTableHeaderCell(
              name: 'Volume',
              onSort: () => model.onSortChanged(MarketSort.volume),
            ),
            const SailTableHeaderCell(name: 'State'),
            const SailTableHeaderCell(name: 'Action'),
          ],
          rowBuilder: (context, row, selected) {
            final market = model.markets[row];
            return [
              SailTableCell(
                value: market.title,
                child: SailColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary13(market.title, bold: true),
                    if (market.description.isNotEmpty)
                      SailText.secondary12(
                        market.description.length > 60
                            ? '${market.description.substring(0, 60)}...'
                            : market.description,
                      ),
                  ],
                ),
              ),
              SailTableCell(value: market.outcomeCount.toString()),
              SailTableCell(
                value: formatter.formatSats(market.volumeSats),
                monospace: true,
              ),
              SailTableCell(
                value: market.marketState.displayName,
                child: _StateChip(state: market.marketState),
              ),
              SailTableCell(
                value: 'View',
                child: SailButton(
                  label: 'View',
                  small: true,
                  onPressed: () async => model.openMarket(context, market.marketId),
                ),
              ),
            ];
          },
          rowCount: model.markets.length,
          emptyPlaceholder: 'No markets match your filters',
          drawGrid: true,
          onDoubleTap: (marketId) => model.openMarket(context, marketId),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailColumn(
        spacing: SailStyleValues.padding04,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12(label),
          SailText.primary20(value, bold: true),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final MarketState state;

  const _StateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    Color bgColor;
    switch (state) {
      case MarketState.trading:
        bgColor = theme.colors.success.withValues(alpha: 0.2);
      case MarketState.ossified:
        bgColor = theme.colors.info.withValues(alpha: 0.2);
      case MarketState.cancelled:
      case MarketState.invalid:
        bgColor = theme.colors.error.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SailText.secondary12(state.displayName),
    );
  }
}

class MarketExplorerViewModel extends BaseViewModel {
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();
  final TextEditingController searchController = TextEditingController();

  List<MarketSummary> get markets => _marketProvider.filteredMarkets;
  bool get isLoading => _marketProvider.isLoading;
  String? get marketError => _marketProvider.error;
  MarketState? get stateFilter => _marketProvider.stateFilter;
  MarketSort get sortBy => _marketProvider.sortBy;

  int get totalMarkets => _marketProvider.markets.length;
  int get activeMarkets => _marketProvider.markets.where((m) => m.isTrading).length;
  double get totalVolumeBTC => _marketProvider.markets.fold(0.0, (sum, m) => sum + satoshiToBTC(m.volumeSats));

  void init() {
    _marketProvider.addListener(_onProviderChange);
    loadMarkets();
  }

  void _onProviderChange() {
    notifyListeners();
  }

  Future<void> loadMarkets() async {
    await _marketProvider.loadMarkets();
  }

  void onSearchChanged(String query) {
    _marketProvider.setSearchQuery(query);
  }

  void onStateFilterChanged(MarketState? state) {
    _marketProvider.setStateFilter(state);
  }

  void onSortChanged(MarketSort sort) {
    _marketProvider.setSort(sort);
  }

  Future<void> openMarket(BuildContext context, String marketId) async {
    await GetIt.I.get<AppRouter>().push(MarketDetailRoute(marketId: marketId));
  }

  Future<void> openCreateMarket(BuildContext context) async {
    await GetIt.I.get<AppRouter>().push(const MarketCreationRoute());
  }

  @override
  void dispose() {
    _marketProvider.removeListener(_onProviderChange);
    searchController.dispose();
    super.dispose();
  }
}
