import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart';
import 'package:stacked/stacked.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:coinshift/widgets/swap/swap_card.dart';
import 'package:coinshift/widgets/swap/swap_status_badge.dart';
import 'package:coinshift/widgets/swap_scheduler_widget.dart';
import 'package:coinshift/widgets/liquidity_monitor_widget.dart';
import 'package:coinshift/widgets/swap_failure_recovery.dart';

class CoinShiftWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'balance_card': HomepageWidgetInfo(
      id: 'balance_card',
      name: 'Balance Card',
      description: 'Shows CoinShift balance',
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
                      description: 'Waiting for coinshift to boot...',
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
            height: 150,
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
                          description: 'Waiting for coinshift to boot...',
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
      description: 'Send CoinShift',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconSend,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 300,
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

    'swap_card': HomepageWidgetInfo(
      id: 'swap_card',
      name: 'Quick Swap',
      description: 'Create a new L2→L1 swap',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconArrowForward,
      builder: (_) => const SwapCard(),
    ),

    'active_swaps': HomepageWidgetInfo(
      id: 'active_swaps',
      name: 'Active Swaps',
      description: 'Shows active swaps with claim buttons',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconTransactions,
      builder: (_) => SizedBox(
        height: 300,
        child: _ActiveSwapsWidget(),
      ),
    ),

    'utxo_table': HomepageWidgetInfo(
      id: 'utxo_table',
      name: 'Transaction History',
      description: 'Shows UTXO and transaction history',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconTransactions,
      builder: (_) => const SizedBox(
        height: 400,
        child: UTXOsTab(),
      ),
    ),

    'swap_scheduler': HomepageWidgetInfo(
      id: 'swap_scheduler',
      name: 'Swap Scheduler',
      description: 'Schedule and create new swaps with advanced options',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconCalendar,
      builder: (_) => const SizedBox(
        height: 450,
        child: SwapSchedulerWidget(),
      ),
    ),

    'liquidity_monitor': HomepageWidgetInfo(
      id: 'liquidity_monitor',
      name: 'Liquidity Monitor',
      description: 'Monitor chain health and liquidity across all chains',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconNetwork,
      builder: (_) => const SizedBox(
        height: 350,
        child: LiquidityMonitorWidget(),
      ),
    ),

    'swap_recovery': HomepageWidgetInfo(
      id: 'swap_recovery',
      name: 'Swap Recovery',
      description: 'Recover and retry failed swaps',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconRestart,
      builder: (_) => const SizedBox(
        height: 400,
        child: SwapFailureRecoveryWidget(),
      ),
    ),
  };

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    return Map.from(_widgets);
  }
}

class _ActiveSwapsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_ActiveSwapsViewModel>.reactive(
      viewModelBuilder: () => _ActiveSwapsViewModel(),
      builder: (context, model, child) {
        final formatter = GetIt.I<FormatterProvider>();

        return SailCard(
          title: 'Active Swaps (${model.activeSwaps.length})',
          bottomPadding: false,
          child: model.activeSwaps.isEmpty
              ? Center(
                  child: SailText.secondary13('No active swaps'),
                )
              : ListenableBuilder(
                  listenable: formatter,
                  builder: (context, child) => ListView.builder(
                    itemCount: model.activeSwaps.length,
                    itemBuilder: (context, index) {
                      final swap = model.activeSwaps[index];
                      return ListTile(
                        leading: SwapStatusBadge(state: swap.state),
                        title: SailText.primary13(
                          '${swap.direction == SwapDirection.l2ToL1 ? 'L2→L1' : 'L1→L2'} - ${formatter.formatSats(swap.l2Amount)}',
                        ),
                        subtitle: SailText.secondary12(
                          'Chain: ${swap.parentChain.value}',
                        ),
                        trailing: swap.state.isReadyToClaim
                            ? SailButton(
                                label: 'Claim',
                                small: true,
                                onPressed: () async => await model.claimSwap(context, swap),
                              )
                            : null,
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

class _ActiveSwapsViewModel extends BaseViewModel {
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();

  List<CoinShiftSwap> get activeSwaps => _swapProvider.activeSwaps;

  _ActiveSwapsViewModel() {
    _swapProvider.addListener(notifyListeners);
  }

  Future<void> claimSwap(BuildContext context, CoinShiftSwap swap) async {
    final txid = await _swapProvider.claimSwap(swap);
    if (txid != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Swap claimed! TXID: $txid')),
      );
    }
  }

  @override
  void dispose() {
    _swapProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

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
              description: 'Waiting for coinshift to boot...',
              child: SailText.secondary15('${formatter.formatBTC(amount)} $ticker'),
            ),
          ],
        ),
      ),
    );
  }
}

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
