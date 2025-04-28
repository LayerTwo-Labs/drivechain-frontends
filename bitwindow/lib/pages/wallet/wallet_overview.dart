import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<OverviewViewModel>.reactive(
          viewModelBuilder: () => OverviewViewModel(),
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                children: [
                  SailRow(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Expanded(
                        child: SailCardStats(
                          title: 'Balance',
                          subtitle: '${formatBitcoin(model.pendingBalance)} pending',
                          value: formatBitcoin(model.balance, symbol: ''),
                          bitcoinAmount: true,
                          icon: SailSVGAsset.bitcoin,
                        ),
                      ),
                      Expanded(
                        child: SailCardStats(
                          title: 'Number of UTXOs',
                          value: model.stats?.utxosCurrent.toString() ?? '0',
                          subtitle:
                              '${model.stats?.utxosUniqueAddresses.toString() ?? '0'} unique address${model.stats?.utxosUniqueAddresses.toInt() == 1 ? '' : 'es'}',
                          icon: SailSVGAsset.bitcoin,
                        ),
                      ),
                      Expanded(
                        child: SailCardStats(
                          title: 'Sidechain Deposit Volume',
                          value: formatBitcoin(model.stats?.sidechainDepositVolume.toInt() ?? 0, symbol: ''),
                          subtitle:
                              '${formatBitcoin(model.stats?.sidechainDepositVolumeLast30Days.toInt() ?? 0, symbol: '')} last 30 days',
                          bitcoinAmount: true,
                          icon: SailSVGAsset.wallet,
                        ),
                      ),
                      Expanded(
                        child: SailCardStats(
                          title: 'Transaction Count',
                          value: model.stats?.transactionCountTotal.toString() ?? '0',
                          subtitle: '${model.stats?.transactionCountSinceMonth.toString() ?? '0'} in last month',
                          icon: SailSVGAsset.activity,
                        ),
                      ),
                    ],
                  ),
                  TransactionTable(
                    entries: model.entries,
                    searchWidget: SailTextField(
                      controller: model.searchController,
                      hintText: 'Enter address or transaction id to search',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TransactionTable extends StatefulWidget {
  final List<WalletTransaction> entries;
  final Widget searchWidget;

  const TransactionTable({
    super.key,
    required this.entries,
    required this.searchWidget,
  });

  @override
  State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
  String sortColumn = 'date';
  bool sortAscending = true;
  List<WalletTransaction> entries = [];

  @override
  void initState() {
    super.initState();
    entries = widget.entries;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!listEquals(entries, widget.entries)) {
      entries = List.from(widget.entries);
      sortEntries();
    }
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
    entries.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'height':
          aValue = a.confirmationTime.height;
          bValue = b.confirmationTime.height;
          break;
        case 'date':
          aValue = a.confirmationTime.timestamp.seconds;
          bValue = b.confirmationTime.timestamp.seconds;
          break;
        case 'txid':
        case 'output':
          // Assuming 'output' is txid for now; adjust if you have a separate output field
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'label':
          aValue = a.label;
          bValue = b.label;
          break;
        case 'amount':
          // Use receivedSatoshi if present, otherwise sentSatoshi
          aValue = a.receivedSatoshi != 0 ? a.receivedSatoshi : a.sentSatoshi;
          bValue = b.receivedSatoshi != 0 ? b.receivedSatoshi : b.sentSatoshi;
          break;
        default:
          aValue = a.confirmationTime.timestamp.seconds;
          bValue = b.confirmationTime.timestamp.seconds;
      }

      // If values are null, treat as empty string or zero for comparison
      aValue ??= '';
      bValue ??= '';

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SailCard(
          title: 'Wallet Transaction History',
          subtitle:
              'List of transactions for your L1-wallet. Contains send, receive and sidechain-interaction transactions.',
          bottomPadding: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: widget.searchWidget,
              ),
              SizedBox(
                height: 300,
                child: SailTable(
                  getRowId: (index) => widget.entries[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(
                      name: 'Date',
                      onSort: () => onSort('date'),
                    ),
                    SailTableHeaderCell(
                      name: 'Output',
                      onSort: () => onSort('output'),
                    ),
                    SailTableHeaderCell(
                      name: 'Address',
                      onSort: () => onSort('address'),
                    ),
                    SailTableHeaderCell(
                      name: 'Label',
                      onSort: () => onSort('label'),
                    ),
                    SailTableHeaderCell(
                      name: 'Amount',
                      onSort: () => onSort('amount'),
                    ),
                  ],
                  rowBuilder: (context, row, selected) {
                    final entry = widget.entries[row];
                    // Format date as "2024 Aug 08"
                    final formattedDate =
                        DateFormat('yyyy MMM dd HH:mm').format(entry.confirmationTime.timestamp.toDateTime().toLocal());
                    // Format amount without BTC symbol
                    final formattedAmount = formatBitcoin(
                      satoshiToBTC(
                        entry.receivedSatoshi != 0 ? entry.receivedSatoshi.toInt() : entry.sentSatoshi.toInt(),
                      ),
                      symbol: '',
                    );
                    // Assuming output, address, label fields exist on WalletTransaction
                    return [
                      SailTableCell(
                        value: formattedDate,
                      ),
                      SailTableCell(
                        value: entry.txid,
                      ),
                      SailTableCell(
                        value: entry.address,
                      ),
                      SailTableCell(
                        value: entry.label,
                      ),
                      SailTableCell(
                        value: formattedAmount,
                        monospace: true,
                      ),
                    ];
                  },
                  rowCount: widget.entries.length,
                  columnWidths: const [120, 120, 320, 120, 120],
                  drawGrid: true,
                  sortColumnIndex: [
                    'date',
                    // Add indices for output, address, label if you implement sorting
                    'amount',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['date', 'output', 'address', 'label', 'amount'][columnIndex]);
                  },
                  onDoubleTap: (rowId) {
                    final utxo = widget.entries.firstWhere(
                      (u) => u.txid == rowId,
                    );
                    _showUtxoDetails(context, utxo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUtxoDetails(BuildContext context, WalletTransaction utxo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'Transaction Details',
            subtitle: 'Details of the selected transaction',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'TxID', value: utxo.txid),
                  DetailRow(label: 'Amount', value: formatBitcoin(satoshiToBTC(utxo.receivedSatoshi.toInt()))),
                  DetailRow(label: 'Date', value: utxo.confirmationTime.timestamp.toDateTime().toLocal().format()),
                  DetailRow(label: 'Confirmation Height', value: utxo.confirmationTime.height.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OverviewViewModel extends BaseViewModel {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  final BitwindowRPC _bitwindowRPC = GetIt.I<BitwindowRPC>();
  final BalanceProvider _balanceProvider = GetIt.I<BalanceProvider>();

  List<WalletTransaction> get entries => _txProvider.walletTransactions
      .where(
        (tx) => searchController.text.isEmpty || tx.txid.contains(searchController.text),
      )
      .toList();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  String sortColumn = 'date';
  bool sortAscending = true;
  GetStatsResponse? stats;

  final TextEditingController searchController = TextEditingController();

  OverviewViewModel() {
    searchController.addListener(notifyListeners);
    _txProvider.addListener(notifyListeners);
    _txProvider.addListener(getStats);
    _balanceProvider.addListener(getStats);
    getStats();
  }

  Future<void> getStats() async {
    stats = await _bitwindowRPC.wallet.getStats();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    _txProvider.removeListener(notifyListeners);
    _txProvider.removeListener(getStats);
    super.dispose();
  }
}
