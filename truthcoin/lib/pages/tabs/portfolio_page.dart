import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/address_position.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/pages/tabs/home_page.dart';
import 'package:truthcoin/providers/voting_provider.dart';
import 'package:truthcoin/routing/router.dart';
import 'package:truthcoin/widgets/market_card.dart';
import 'package:truthcoin/widgets/market_stat_tile.dart';

@RoutePage()
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PortfolioViewModel>.reactive(
      viewModelBuilder: () => PortfolioViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return QtPage(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              _Header(model: model),
              _StatTiles(model: model),
              Expanded(child: _PositionsCard(model: model)),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final PortfolioViewModel model;

  const _Header({required this.model});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SailStyleValues.padding12,
      runSpacing: SailStyleValues.padding08,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            children: [
              SailText.primary24('Portfolio', bold: true),
              SailText.secondary13(
                model.addresses.isEmpty
                    ? 'No wallet address yet'
                    : '${model.headlineAddress} · ${model.addresses.length} addresses',
              ),
            ],
          ),
        ),
        SailButton(
          label: 'Refresh',
          variant: ButtonVariant.secondary,
          small: true,
          loading: model.isLoading,
          onPressed: () async => model.load(),
        ),
        SailButton(
          label: 'Markets',
          small: true,
          onPressed: () async => model.openMarkets(context),
        ),
      ],
    );
  }
}

class _StatTiles extends StatelessWidget {
  final PortfolioViewModel model;

  const _StatTiles({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I.get<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, _) => MarketStatTileRow(
        tiles: [
          MarketStatTile(
            label: 'Portfolio value',
            value: formatter.formatSats(model.totalValueSats),
            caption: 'value of every open share',
          ),
          MarketStatTile(
            label: 'Profit and loss',
            value: '${model.totalProfitSats >= 0 ? '+' : ''}${model.profitPercent.toStringAsFixed(1)}%',
            caption: 'cost ${formatter.formatSats(model.totalCostBasisSats)}',
            valueColor: model.hasProfit ? theme.colors.success : theme.colors.error,
          ),
          MarketStatTile(
            label: 'Open positions',
            value: '${model.positions.length}',
            caption: 'across ${model.activeMarkets} markets',
          ),
          MarketStatTile(
            label: 'Votecoin',
            value: '${model.votecoinBalance}',
            caption: 'weight of your oracle vote',
          ),
        ],
      ),
    );
  }
}

class _PositionsCard extends StatelessWidget {
  final PortfolioViewModel model;

  const _PositionsCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I.get<FormatterProvider>();

    if (model.isLoading && model.positions.isEmpty) {
      return Center(
        child: SailSkeletonizer(
          enabled: true,
          description: 'Positions load',
          child: SailText.primary15('Positions load'),
        ),
      );
    }

    if (model.loadError != null) {
      return Center(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.primary15(model.loadError!),
            SailButton(label: 'Try again', small: true, onPressed: () async => model.load()),
          ],
        ),
      );
    }

    if (model.positions.isEmpty) {
      return Center(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.secondary15('You hold no share yet'),
            SailButton(
              label: 'Open the markets',
              small: true,
              onPressed: () async => model.openMarkets(context),
            ),
          ],
        ),
      );
    }

    return SailCard(
      title: 'Open positions',
      bottomPadding: false,
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailTable(
          getRowId: (index) =>
              '${model.positions[index].address}-${model.positions[index].position.marketId}-'
              '${model.positions[index].position.outcomeIndex}',
          headerBuilder: (context) => const [
            SailTableHeaderCell(name: 'Market'),
            SailTableHeaderCell(name: 'Outcome'),
            SailTableHeaderCell(name: 'Address'),
            SailTableHeaderCell(name: 'Shares'),
            SailTableHeaderCell(name: 'Average price'),
            SailTableHeaderCell(name: 'Price'),
            SailTableHeaderCell(name: 'Value'),
            SailTableHeaderCell(name: 'Profit'),
            SailTableHeaderCell(name: 'Action'),
          ],
          rowBuilder: (context, row, selected) {
            final holder = model.positions[row];
            final position = holder.position;
            return [
              SailTableCell(value: model.marketTitle(position.marketId)),
              SailTableCell(
                value: position.outcomeName,
                child: SailBadge(position.outcomeName),
              ),
              SailTableCell(value: model.shortAddress(holder.address), monospace: true),
              SailTableCell(value: '${position.shares}', monospace: true),
              SailTableCell(value: formatChance(position.avgPurchasePrice), monospace: true),
              SailTableCell(value: formatChance(position.currentPrice), monospace: true),
              SailTableCell(value: formatter.formatSats(position.currentValueSats), monospace: true),
              SailTableCell(
                value: position.pnlDisplay,
                monospace: true,
                textColor: position.isProfit ? theme.colors.success : theme.colors.error,
              ),
              SailTableCell(
                value: 'Trade',
                child: SailButton(
                  label: 'Trade',
                  small: true,
                  insideTable: true,
                  onPressed: () async => model.openMarket(position.marketId, position.outcomeIndex),
                ),
              ),
            ];
          },
          rowCount: model.positions.length,
          emptyPlaceholder: 'You hold no share yet',
          drawGrid: true,
        ),
      ),
    );
  }
}

class PortfolioViewModel extends BaseViewModel {
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();
  final VotingProvider _votingProvider = GetIt.I.get<VotingProvider>();
  final TruthcoinRPC _rpc = GetIt.I.get<TruthcoinRPC>();

  List<String> addresses = [];
  List<AddressPosition> positions = [];
  int votecoinBalance = 0;
  int totalValueSats = 0;
  int totalCostBasisSats = 0;
  int totalProfitSats = 0;
  int activeMarkets = 0;
  bool isLoading = false;
  String? loadError;

  double get profitPercent => totalCostBasisSats > 0 ? totalProfitSats / totalCostBasisSats * 100 : 0;
  bool get hasProfit => totalProfitSats > 0;

  /// The first address stands for the wallet in the page header.
  String? get headlineAddress => addresses.isEmpty ? null : addresses.first;

  void init() {
    _marketProvider.addListener(_onProviderChange);
    load();
  }

  void _onProviderChange() {
    notifyListeners();
  }

  String marketTitle(String marketId) {
    final match = _marketProvider.markets.where((m) => m.marketId == marketId);
    if (match.isNotEmpty) return match.first.title;
    return _marketProvider.marketDetails[marketId]?.title ?? marketId;
  }

  String shortAddress(String address) {
    if (address.length <= 14) return address;
    return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
  }

  /// Reads every wallet address, because a position sits on one address only.
  Future<void> load() async {
    isLoading = true;
    loadError = null;
    addresses = [];
    positions = [];
    totalValueSats = 0;
    totalCostBasisSats = 0;
    totalProfitSats = 0;
    activeMarkets = 0;
    votecoinBalance = 0;
    notifyListeners();

    try {
      addresses = await _rpc.getWalletAddresses();
    } catch (e) {
      loadError = 'Failed to read the wallet addresses: $e';
      isLoading = false;
      notifyListeners();
      return;
    }

    await _marketProvider.loadMarkets();

    final collected = <AddressPosition>[];
    final marketIds = <String>{};
    var value = 0;
    var costBasis = 0;
    var profit = 0;
    var votecoin = 0;

    for (final address in addresses) {
      try {
        final response = await _rpc.marketPositions(address: address);
        final holdings = UserHoldings.fromJson(response);
        for (final position in holdings.positions) {
          collected.add(AddressPosition(address, position));
          marketIds.add(position.marketId);
        }
        value += holdings.totalValueSats;
        costBasis += holdings.totalCostBasisSats;
        profit += holdings.totalUnrealizedPnlSats;
      } catch (e) {
        loadError = 'Failed to load the positions of $address: $e';
        isLoading = false;
        notifyListeners();
        return;
      }

      try {
        votecoin += await _votingProvider.getVotecoinBalance(address);
      } catch (e) {
        loadError = 'Failed to read the Votecoin of $address: $e';
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    positions = collected;
    activeMarkets = marketIds.length;
    totalValueSats = value;
    totalCostBasisSats = costBasis;
    totalProfitSats = profit;
    votecoinBalance = votecoin;

    isLoading = false;
    notifyListeners();
  }

  void openMarkets(BuildContext context) {
    AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.Markets.index);
  }

  Future<void> openMarket(String marketId, int? outcomeIndex) async {
    await GetIt.I.get<AppRouter>().push(
      MarketDetailRoute(marketId: marketId, initialOutcomeIndex: outcomeIndex),
    );
  }

  @override
  void dispose() {
    _marketProvider.removeListener(_onProviderChange);
    super.dispose();
  }
}
