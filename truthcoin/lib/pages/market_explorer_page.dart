import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/routing/open_market.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/routing/router.dart';
import 'package:truthcoin/widgets/market_card.dart';

const double _cardGap = SailStyleValues.padding16;
const int _maxCardsPerRow = 3;

/// A card holds its content at this width.
const double _minCardWidth = 330;

/// Below this width the header controls sit under the title.
const double _wideHeaderWidth = 900;

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
              _FilterChips(model: model),
              Expanded(child: _MarketGrid(model: model)),
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
    final formatter = GetIt.I.get<FormatterProvider>();

    final title = ListenableBuilder(
      listenable: formatter,
      builder: (context, _) => SailColumn(
        spacing: SailStyleValues.padding04,
        children: [
          SailText.primary24('Prediction markets', bold: true),
          SailText.secondary13(
            '${model.totalMarkets} markets  ·  ${model.activeMarkets} live  ·  '
            '${formatter.formatBTC(model.totalVolumeBTC)} traded',
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < _wideHeaderWidth;
        final controls = [
          SizedBox(
            width: narrow ? 180 : 280,
            child: SailTextField(
              controller: model.searchController,
              hintText: 'Search markets',
              size: TextFieldSize.small,
              onChanged: model.onSearchChanged,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: SailStyleValues.padding10),
                child: SailSVG.fromAsset(
                  SailSVGAsset.search,
                  width: 14,
                  height: 14,
                  color: SailTheme.of(context).colors.icon,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 14),
            ),
          ),
          SizedBox(
            width: 150,
            child: SailDropdownButton<MarketSort>(
              value: model.sortBy,
              items: const [
                SailDropdownItem<MarketSort>(value: MarketSort.volume, label: 'By volume'),
                SailDropdownItem<MarketSort>(value: MarketSort.created, label: 'By date'),
                SailDropdownItem<MarketSort>(value: MarketSort.title, label: 'By title'),
              ],
              onChanged: (sort) {
                if (sort != null) model.onSortChanged(sort);
              },
            ),
          ),
          SailButton(
            label: 'Refresh',
            variant: ButtonVariant.secondary,
            small: true,
            loading: model.isLoading || model.isLoadingPrices,
            onPressed: () async => model.loadMarkets(refresh: true),
          ),
          SailButton(
            label: 'Create market',
            icon: SailSVGAsset.plus,
            small: true,
            onPressed: () async => model.openCreateMarket(),
          ),
        ];

        if (narrow) {
          return SailColumn(
            spacing: SailStyleValues.padding12,
            children: [
              title,
              Wrap(
                spacing: SailStyleValues.padding08,
                runSpacing: SailStyleValues.padding08,
                children: controls,
              ),
            ],
          );
        }

        return SailRow(
          spacing: SailStyleValues.padding12,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: title),
            ...controls,
          ],
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  final MarketExplorerViewModel model;

  const _FilterChips({required this.model});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SailStyleValues.padding08,
      runSpacing: SailStyleValues.padding08,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterChip(
          label: 'All',
          selected: model.stateFilter == null && model.tagFilter == null,
          onTap: model.clearFilters,
        ),
        for (final tag in model.availableTags)
          _FilterChip(
            label: tag,
            selected: model.tagFilter == tag,
            onTap: () => model.onTagFilterChanged(model.tagFilter == tag ? null : tag),
          ),
        for (final state in MarketState.values)
          _FilterChip(
            label: state.displayName,
            selected: model.stateFilter == state,
            onTap: () => model.onStateFilterChanged(model.stateFilter == state ? null : state),
          ),
        if (model.isLoadingPrices) SailText.secondary12('prices load'),
        if (model.priceError != null) SailText.secondary12(model.priceError!),
      ],
    );
  }
}

/// A rounded state filter, drawn as a pill.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailTappable(
      onTap: () async => onTap(),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding12,
          vertical: SailStyleValues.padding08,
        ),
        decoration: BoxDecoration(
          color: selected ? theme.colors.text : theme.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: SailText.primary12(
          label,
          bold: selected,
          color: selected ? theme.colors.background : theme.colors.textSecondary,
        ),
      ),
    );
  }
}

class _MarketGrid extends StatelessWidget {
  final MarketExplorerViewModel model;

  const _MarketGrid({required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.isLoading && model.markets.isEmpty) {
      return Center(
        child: SailSkeletonizer(
          enabled: true,
          description: 'Markets load',
          child: SailText.primary15('Markets load'),
        ),
      );
    }

    if (model.marketError != null) {
      return Center(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.primary15(model.marketError!),
            SailButton(
              label: 'Try again',
              small: true,
              onPressed: () async => model.loadMarkets(refresh: true),
            ),
          ],
        ),
      );
    }

    if (model.markets.isEmpty) {
      return Center(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.secondary15('No market matches the filter'),
            SailButton(
              label: 'Create the first market',
              small: true,
              onPressed: () async => model.openCreateMarket(),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = ((constraints.maxWidth + _cardGap) / (_minCardWidth + _cardGap)).floor();
        final columns = fit.clamp(1, _maxCardsPerRow);
        final cardWidth = (constraints.maxWidth - _cardGap * (columns - 1)) / columns;

        return SingleChildScrollView(
          child: Wrap(
            spacing: _cardGap,
            runSpacing: _cardGap,
            children: [
              for (final market in model.markets)
                SizedBox(
                  width: cardWidth,
                  child: MarketCard(
                    market: market,
                    detail: model.marketDetails[market.marketId],
                    onTap: () => model.openMarket(market.marketId),
                    onTradeOutcome: (outcomeIndex) => model.openMarket(
                      market.marketId,
                      outcomeIndex: outcomeIndex,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class MarketExplorerViewModel extends BaseViewModel {
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();
  final TextEditingController searchController = TextEditingController();

  List<MarketSummary> get markets => _marketProvider.filteredMarkets;
  Map<String, MarketData> get marketDetails => _marketProvider.marketDetails;
  bool get isLoading => _marketProvider.isLoading;
  bool get isLoadingPrices => _marketProvider.isLoadingPrices;
  String? get marketError => _marketProvider.error;
  String? get priceError => _marketProvider.priceError;
  MarketState? get stateFilter => _marketProvider.stateFilter;
  String? get tagFilter => _marketProvider.tagFilter;
  List<String> get availableTags => _marketProvider.availableTags;
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

  Future<void> loadMarkets({bool refresh = false}) async {
    await _marketProvider.loadMarkets();
    await _marketProvider.loadMarketPrices(refresh: refresh);
  }

  void onSearchChanged(String query) {
    _marketProvider.setSearchQuery(query);
  }

  void onStateFilterChanged(MarketState? state) {
    _marketProvider.setStateFilter(state);
  }

  void onTagFilterChanged(String? tag) {
    _marketProvider.setTagFilter(tag);
  }

  void clearFilters() {
    _marketProvider.setStateFilter(null);
    _marketProvider.setTagFilter(null);
  }

  void onSortChanged(MarketSort sort) {
    _marketProvider.setSort(sort);
  }

  Future<void> openMarket(String marketId, {int? outcomeIndex}) async {
    await openMarketsRoute(
      MarketDetailRoute(marketId: marketId, initialOutcomeIndex: outcomeIndex),
    );
  }

  Future<void> openCreateMarket() async {
    await openMarketsRoute(const MarketCreationRoute());
    // A new market carries no price yet, so the grid reads the list again.
    await loadMarkets();
  }

  @override
  void dispose() {
    _marketProvider.removeListener(_onProviderChange);
    searchController.dispose();
    super.dispose();
  }
}
