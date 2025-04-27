import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<LatestWalletTransactionsViewModel>.reactive(
          viewModelBuilder: () => LatestWalletTransactionsViewModel(),
          builder: (context, model, child) {
            return TransactionTable(
              entries: model.entries,
              searchWidget: SailTextField(
                controller: model.searchController,
                hintText: 'Enter address or transaction id to search',
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
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'amount':
          aValue = a.receivedSatoshi;
          bValue = b.receivedSatoshi;
          break;
      }

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
              'List of transactions for your bitcoin-wallet. Contains send, receive and sidechain-interaction transactions.',
          bottomPadding: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: widget.searchWidget,
              ),
              Expanded(
                child: SailTable(
                  getRowId: (index) => widget.entries[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(
                      name: 'Conf Height',
                      onSort: () => onSort('height'),
                    ),
                    SailTableHeaderCell(
                      name: 'Date',
                      onSort: () => onSort('date'),
                    ),
                    SailTableHeaderCell(
                      name: 'TxID',
                      onSort: () => onSort('txid'),
                    ),
                    SailTableHeaderCell(
                      name: 'Amount',
                      onSort: () => onSort('amount'),
                    ),
                  ],
                  rowBuilder: (context, row, selected) {
                    final entry = widget.entries[row];
                    final amount = entry.receivedSatoshi != 0
                        ? formatBitcoin(satoshiToBTC(entry.receivedSatoshi.toInt()))
                        : formatBitcoin(satoshiToBTC(entry.sentSatoshi.toInt()));

                    return [
                      SailTableCell(
                        value: entry.confirmationTime.height == 0
                            ? 'Unconfirmed'
                            : entry.confirmationTime.height.toString(),
                        monospace: true,
                      ),
                      SailTableCell(
                        value: entry.confirmationTime.timestamp.toDateTime().toLocal().format(),
                        monospace: true,
                      ),
                      SailTableCell(
                        value: entry.txid,
                        monospace: true,
                      ),
                      SailTableCell(
                        value: amount,
                        monospace: true,
                      ),
                    ];
                  },
                  rowCount: widget.entries.length,
                  columnWidths: const [100, 150, 200, 150],
                  drawGrid: true,
                  sortColumnIndex: [
                    'height',
                    'date',
                    'txid',
                    'amount',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['height', 'date', 'txid', 'amount'][columnIndex]);
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

class LatestWalletTransactionsViewModel extends BaseViewModel {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  List<WalletTransaction> get entries => _txProvider.walletTransactions
      .where(
        (tx) => searchController.text.isEmpty || tx.txid.contains(searchController.text),
      )
      .toList();

  String sortColumn = 'date';
  bool sortAscending = true;

  final TextEditingController searchController = TextEditingController();

  LatestWalletTransactionsViewModel() {
    searchController.addListener(notifyListeners);
    _txProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    _txProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
