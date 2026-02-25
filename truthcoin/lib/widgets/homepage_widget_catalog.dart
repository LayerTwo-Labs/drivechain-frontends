import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';
import 'package:truthcoin/routing/router.dart';

class TruthcoinWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'balance_card': HomepageWidgetInfo(
      id: 'balance_card',
      name: 'Balance Card',
      description: 'Shows Truthcoin balance',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconWallet,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          final formatter = GetIt.I<FormatterProvider>();

          return ListenableBuilder(
            listenable: formatter,
            builder: (context, child) => SizedBox(
              child: SailCard(
                title: 'Balance',
                child: SailColumn(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailSkeletonizer(
                      enabled: !model.balanceInitialized,
                      description: 'Waiting for truthcoin to boot...',
                      child: SailText.primary24(
                        '${formatter.formatBTC(model.totalBalance)} ${model.ticker}',
                        bold: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BalanceRow(
                      label: 'Available',
                      amount: model.balance,
                      ticker: model.ticker,
                      loading: !model.balanceInitialized,
                    ),
                    BalanceRow(
                      label: 'Pending',
                      amount: model.pendingBalance,
                      ticker: model.ticker,
                      loading: !model.balanceInitialized,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),

    'receive_card': HomepageWidgetInfo(
      id: 'receive_card',
      name: 'Receive Card',
      description: 'Shows receive address',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconReceive,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 150, // Fixed height to prevent layout issues
            child: SailCard(
              title: 'Receive on Sidechain',
              error: model.receiveError,
              child: SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailColumn(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailTextField(
                        loading: LoadingDetails(
                          enabled: model.receiveAddress == null,
                          description: 'Waiting for truthcoin to boot...',
                        ),
                        controller: TextEditingController(text: model.receiveAddress),
                        hintText: 'Generating deposit address...',
                        readOnly: true,
                        suffixWidget: CopyButton(text: model.receiveAddress ?? ''),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'send_card': HomepageWidgetInfo(
      id: 'send_card',
      name: 'Send Card',
      description: 'Send Truthcoin',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconSend,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 300, // Fixed height for send form
            child: SailCard(
              title: 'Send on Sidechain',
              error: model.sendError,
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                children: [
                  SailText.secondary15('Pay to'),
                  SailTextField(
                    controller: model.bitcoinAddressController,
                    hintText: 'Enter a bitcoin address',
                  ),
                  NumericField(
                    label: 'Amount',
                    controller: model.bitcoinAmountController,
                    hintText: '0.00',
                  ),
                  SailButton(
                    label: 'Send',
                    disabled: !model.canSend,
                    onPressed: () async => await model.executeSendOnSidechain(context),
                    loading: model.isSending,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'utxo_table': HomepageWidgetInfo(
      id: 'utxo_table',
      name: 'Transaction History',
      description: 'Shows UTXO and transaction history',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconTransactions,
      builder: (_) => SizedBox(
        height: 400, // Fixed height to prevent layout issues
        child: const UTXOsTab(),
      ),
    ),

    'market_summary': HomepageWidgetInfo(
      id: 'market_summary',
      name: 'Top Markets',
      description: 'Shows top prediction markets by volume',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconHome,
      builder: (_) => const _MarketSummaryWidget(),
    ),

    'positions_summary': HomepageWidgetInfo(
      id: 'positions_summary',
      name: 'Your Positions',
      description: 'Shows your market positions summary',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconWallet,
      builder: (_) => const _PositionsSummaryWidget(),
    ),

    'voting_status': HomepageWidgetInfo(
      id: 'voting_status',
      name: 'Voting Status',
      description: 'Shows current voting period and your status',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconPen,
      builder: (_) => const _VotingStatusWidget(),
    ),
  };

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    return Map.from(_widgets);
  }
}

// Copy the exact BalanceRow from the working page
class BalanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final String ticker;
  final bool loading;

  const BalanceRow({
    super.key,
    required this.label,
    required this.amount,
    required this.ticker,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.secondary15(label),
            SailSkeletonizer(
              enabled: loading,
              description: 'Waiting for truthcoin to boot...',
              child: SailText.secondary15('${formatter.formatBTC(amount)} $ticker'),
            ),
          ],
        ),
      ),
    );
  }
}

// Copy the exact UTXOsTab from the working page
class UTXOsTab extends StatelessWidget {
  const UTXOsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<LatestUTXOsViewModel>.reactive(
          viewModelBuilder: () => LatestUTXOsViewModel(),
          builder: (context, model, child) {
            return UTXOTable(entries: model.entries, model: model);
          },
        );
      },
    );
  }
}

class UTXOTable extends StatefulWidget {
  final List<SidechainUTXO> entries;
  final LatestUTXOsViewModel model;

  const UTXOTable({super.key, required this.entries, required this.model});

  @override
  State<UTXOTable> createState() => _UTXOTableState();
}

class _UTXOTableState extends State<UTXOTable> {
  String sortColumn = 'output';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    sortEntries();
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortEntries();
    });
  }

  void sortEntries() {
    widget.entries.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'output':
          aValue = a.outpoint;
          bValue = b.outpoint;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'value':
          aValue = a.valueSats;
          bValue = b.valueSats;
          break;
        case 'type':
          aValue = a.type;
          bValue = b.type;
          break;
        default:
          aValue = a.valueSats;
          bValue = b.valueSats;
      }
      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SailCard(
      title: 'Your UTXOs',
      bottomPadding: false,
      child: Column(
        children: [
          Expanded(
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to start and wallet to sync..',
              enabled: widget.model.loading,
              child: ListenableBuilder(
                listenable: formatter,
                builder: (context, child) => SailTable(
                  shrinkWrap: true,
                  getRowId: (index) => widget.entries[index].outpoint.split(':').first,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(name: 'Type', onSort: () => onSort('type')),
                    SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
                    SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                    SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
                  ],
                  rowBuilder: (context, row, selected) {
                    final utxo = widget.entries[row];
                    final formattedAmount = formatter
                        .formatSats(utxo.valueSats.toInt())
                        .replaceAll(' ${formatter.currentUnit.symbol}', '');
                    return [
                      SailTableCell(value: utxo.type.name, monospace: true),
                      SailTableCell(
                        value: '${utxo.outpoint.substring(0, 6)}..:${utxo.outpoint.split(':').last}',
                        copyValue: utxo.outpoint,
                      ),
                      SailTableCell(value: utxo.address, monospace: true),
                      SailTableCell(value: formattedAmount, monospace: true),
                    ];
                  },
                  rowCount: widget.entries.length,
                  emptyPlaceholder: 'No UTXOs in wallet',
                  drawGrid: true,
                  sortColumnIndex: ['type', 'output', 'address', 'value'].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['type', 'output', 'address', 'value'][columnIndex]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LatestUTXOsViewModel extends BaseViewModel with ChangeTrackingMixin {
  final SidechainTransactionsProvider _txProvider = GetIt.I<SidechainTransactionsProvider>();
  final EnforcerRPC _enforcerRPC = GetIt.I<EnforcerRPC>();

  List<SidechainUTXO> get entries {
    if (loading) {
      return [
        SidechainUTXO(
          outpoint: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3:1',
          address: '5M2AwMwMsRVGKyFo2zfo6A774Oh',
          valueSats: 2500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4:2',
          address: '6N3BxNxNtSWHLzGp3agp7B885Pi',
          valueSats: 500000000,
          type: OutpointType.regular,
        ),
      ];
    }

    return _txProvider.utxos.toList();
  }

  LatestUTXOsViewModel() {
    initChangeTracker();
    _txProvider.addListener(_onChange);
  }

  void _onChange() {
    track('entries', entries);
    track('loading', loading);
    notifyIfChanged();
  }

  bool get loading => _enforcerRPC.initializingBinary;

  @override
  void dispose() {
    _txProvider.removeListener(_onChange);
    super.dispose();
  }
}

/// Market summary widget for homepage
class _MarketSummaryWidget extends StatelessWidget {
  const _MarketSummaryWidget();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_MarketSummaryViewModel>.reactive(
      viewModelBuilder: () => _MarketSummaryViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        final formatter = GetIt.I<FormatterProvider>();

        return ListenableBuilder(
          listenable: formatter,
          builder: (context, _) => SailCard(
            title: 'Top Markets',
            child: model.isLoading
                ? SailSkeletonizer(
                    enabled: true,
                    description: 'Loading markets...',
                    child: SailText.primary15('Loading...'),
                  )
                : model.topMarkets.isEmpty
                ? SailColumn(
                    children: [
                      SailText.secondary15('No markets yet'),
                      const SizedBox(height: 8),
                      SailButton(
                        label: 'Create Market',
                        small: true,
                        onPressed: () async {
                          await GetIt.I.get<AppRouter>().push(const MarketCreationRoute());
                        },
                      ),
                    ],
                  )
                : SailColumn(
                    spacing: SailStyleValues.padding08,
                    children: [
                      ...model.topMarkets
                          .take(3)
                          .map(
                            (market) => GestureDetector(
                              onTap: () => GetIt.I.get<AppRouter>().push(MarketDetailRoute(marketId: market.marketId)),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: SailRow(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: SailText.primary13(
                                        market.title.length > 30 ? '${market.title.substring(0, 30)}...' : market.title,
                                      ),
                                    ),
                                    SailText.secondary12(formatter.formatSats(market.volumeSats)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      const Divider(),
                      SailButton(
                        label: 'View All Markets',
                        small: true,
                        onPressed: () async {
                          await GetIt.I.get<AppRouter>().push(const MarketExplorerRoute());
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _MarketSummaryViewModel extends BaseViewModel {
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();

  List<MarketSummary> get topMarkets =>
      _marketProvider.markets.where((m) => m.isTrading).toList()..sort((a, b) => b.volumeSats.compareTo(a.volumeSats));

  bool get isLoading => _marketProvider.isLoading;

  void init() {
    _marketProvider.addListener(notifyListeners);
    _marketProvider.loadMarkets();
  }

  @override
  void dispose() {
    _marketProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Positions summary widget for homepage
class _PositionsSummaryWidget extends StatelessWidget {
  const _PositionsSummaryWidget();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_PositionsSummaryViewModel>.reactive(
      viewModelBuilder: () => _PositionsSummaryViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);
        final formatter = GetIt.I<FormatterProvider>();

        return ListenableBuilder(
          listenable: formatter,
          builder: (context, _) => SailCard(
            title: 'Your Positions',
            child: model.isLoading
                ? SailSkeletonizer(
                    enabled: true,
                    description: 'Loading positions...',
                    child: SailText.primary15('Loading...'),
                  )
                : model.holdings == null || model.holdings!.positions.isEmpty
                ? SailText.secondary15('No positions yet')
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

class _PositionsSummaryViewModel extends BaseViewModel {
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();
  final TruthcoinRPC _rpc = GetIt.I.get<TruthcoinRPC>();

  UserHoldings? get holdings => _marketProvider.userPositions;
  bool isLoading = false;

  void init() {
    _marketProvider.addListener(notifyListeners);
    loadPositions();
  }

  Future<void> loadPositions() async {
    isLoading = true;
    notifyListeners();

    try {
      final addresses = await _rpc.getWalletAddresses();
      if (addresses.isNotEmpty) {
        await _marketProvider.loadUserPositions(addresses.first);
      }
    } catch (e) {
      // Ignore
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _marketProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Voting status widget for homepage
class _VotingStatusWidget extends StatelessWidget {
  const _VotingStatusWidget();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_VotingStatusViewModel>.reactive(
      viewModelBuilder: () => _VotingStatusViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);

        return SailCard(
          title: 'Voting Status',
          child: model.isLoading
              ? SailSkeletonizer(
                  enabled: true,
                  description: 'Loading voting info...',
                  child: SailText.primary15('Loading...'),
                )
              : SailColumn(
                  spacing: SailStyleValues.padding08,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (model.slotStatus != null) ...[
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.secondary13('Current Period'),
                          SailText.primary15(model.slotStatus!.currentPeriodName, bold: true),
                        ],
                      ),
                    ],
                    if (model.currentPeriod != null) ...[
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.secondary13('Status'),
                          SailText.primary13(
                            model.currentPeriod!.status.toUpperCase(),
                            color: model.currentPeriod!.isActive ? theme.colors.success : theme.colors.text,
                          ),
                        ],
                      ),
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.secondary13('Decisions'),
                          SailText.primary13(model.currentPeriod!.decisions.length.toString()),
                        ],
                      ),
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.secondary13('Participation'),
                          SailText.primary13(model.currentPeriod!.stats.participationPercent),
                        ],
                      ),
                    ],
                    if (model.pendingVotesCount > 0)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SailText.primary13(
                          '${model.pendingVotesCount} pending votes',
                          bold: true,
                        ),
                      ),
                    const Divider(),
                    SailButton(
                      label: 'Go to Voting',
                      small: true,
                      onPressed: () async {
                        await GetIt.I.get<AppRouter>().push(const VotingDashboardRoute());
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _VotingStatusViewModel extends BaseViewModel {
  final VotingProvider _votingProvider = GetIt.I.get<VotingProvider>();

  SlotStatus? get slotStatus => _votingProvider.slotStatus;
  VotingPeriodFull? get currentPeriod => _votingProvider.currentPeriod;
  int get pendingVotesCount => _votingProvider.pendingVotes.length;
  bool get isLoading => _votingProvider.isLoading;

  void init() {
    _votingProvider.addListener(notifyListeners);
    loadData();
  }

  Future<void> loadData() async {
    await _votingProvider.loadSlotStatus();
    await _votingProvider.loadCurrentPeriod();
  }

  @override
  void dispose() {
    _votingProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
