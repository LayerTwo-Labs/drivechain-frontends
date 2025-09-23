import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart';
import 'package:stacked/stacked.dart';

class ThunderWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'balance_card': HomepageWidgetInfo(
      id: 'balance_card',
      name: 'Balance Card',
      description: 'Shows Thunder balance',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconWallet,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 181, // Fixed height like the original
            child: SailCard(
              title: 'Balance',
              child: SailColumn(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailSkeletonizer(
                    enabled: !model.balanceInitialized,
                    description: 'Waiting for thunder to boot...',
                    child: SailText.primary24(
                      '${formatBitcoin(model.totalBalance)} ${model.ticker}',
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
          return SailCard(
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
                        description: 'Waiting for thunder to boot...',
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
          );
        },
      ),
    ),

    'send_card': HomepageWidgetInfo(
      id: 'send_card',
      name: 'Send Card',
      description: 'Send Thunder',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconSend,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SailCard(
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
                  onPressed: () async => await model.executeSendOnSidechain(context),
                  loading: model.isSending,
                ),
              ],
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
      builder: (_) => const UTXOsTab(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary15(label),
          SailSkeletonizer(
            enabled: loading,
            description: 'Waiting for thunder to boot...',
            child: SailText.secondary15('${formatBitcoin(amount)} $ticker'),
          ),
        ],
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
    return SailCard(
      title: 'Your UTXOs',
      bottomPadding: false,
      child: Column(
        children: [
          Expanded(
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to start and wallet to sync..',
              enabled: widget.model.loading,
              child: SailTable(
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
                  final formattedAmount = formatBitcoin(satoshiToBTC(utxo.valueSats), symbol: '');
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
                drawGrid: true,
                sortColumnIndex: ['type', 'output', 'address', 'value'].indexOf(sortColumn),
                sortAscending: sortAscending,
                onSort: (columnIndex, ascending) {
                  onSort(['type', 'output', 'address', 'value'][columnIndex]);
                },
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
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
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
