import 'package:bitwindow/gen/wallet/v1/wallet.pb.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<AddressMenuViewModel>.reactive(
          viewModelBuilder: () => AddressMenuViewModel(),
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
  final List<Transaction> entries;
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
  String sortColumn = 'conf';
  bool sortAscending = true;
  List<Transaction> entries = [];

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
        case 'conf':
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
        return SailRawCard(
          title: 'Your Wallet Transaction History',
          bottomPadding: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: widget.searchWidget,
              ),
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight - 116, // 116 is the height of the search widget and padding
                child: SailTable(
                  getRowId: (index) => widget.entries[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(
                      name: 'Conf',
                      onSort: () => onSort('conf'),
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
                    return [
                      SailTableCell(
                        child: SailText.primary12(
                          entry.confirmationTime.height.toString(),
                          monospace: true,
                        ),
                      ),
                      SailTableCell(
                        child: SailText.primary12(
                          entry.confirmationTime.timestamp.toDateTime().format(),
                          monospace: true,
                        ),
                      ),
                      SailTableCell(
                        child: SailText.primary12(
                          entry.txid,
                          monospace: true,
                        ),
                      ),
                      SailTableCell(
                        child: SailText.primary12(
                          formatBitcoin(satoshiToBTC(entry.receivedSatoshi.toInt())),
                          monospace: true,
                        ),
                      ),
                    ];
                  },
                  rowCount: widget.entries.length,
                  columnWidths: const [100, 150, 200, 150],
                  drawGrid: true,
                  sortColumnIndex: [
                    'conf',
                    'date',
                    'txid',
                    'amount',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['conf', 'date', 'txid', 'amount'][columnIndex]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddressMenuViewModel extends BaseViewModel {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  List<Transaction> get entries => _txProvider.walletTransactions
      .where(
        (tx) => searchController.text.isEmpty || tx.txid.contains(searchController.text),
      )
      // if empty, mock some data
      .toList();

  String sortColumn = 'conf';
  bool sortAscending = true;

  final TextEditingController searchController = TextEditingController();

  AddressMenuViewModel() {
    searchController.addListener(notifyListeners);
  }

  void onChoosePressed(BuildContext context) {
    // TODO: Implement expansion logic
  }
}

Future<CoreTransaction?> showAddressBookModal(BuildContext context) {
  return showDialog<CoreTransaction>(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.1,
        ),
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: context.sailTheme.colors.formFieldBorder,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding25,
              vertical: SailStyleValues.padding16,
            ),
            child: Container(),
          ),
        ),
      );
    },
  );
}
