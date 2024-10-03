import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/gen/wallet/v1/wallet.pb.dart';
import 'package:drivechain_client/providers/transactions_provider.dart';
import 'package:drivechain_client/widgets/qt_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddressMenuViewModel>.reactive(
      viewModelBuilder: () => AddressMenuViewModel(),
      builder: (context, model, child) {
        return QtPage(
          child: Column(
            children: [
              SailTextField(controller: model.searchController, hintText: 'Enter address or transaction id to search'),
              const SizedBox(height: 8),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: TransactionTable(
                    entries: model.entries,
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

class TransactionTable extends StatefulWidget {
  final List<Transaction> entries;

  const TransactionTable({
    super.key,
    required this.entries,

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
    if(!listEquals(entries, widget.entries)) {
      entries = widget.entries;
      onSort(sortColumn);
    }
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortEntries();
    setState(() {});
  }

  void sortEntries() {
    entries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';
      
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
    return SailTable(
      headerBuilder: (context) => [
        SailTableHeaderCell(
          child: SailText.primary12('Conf'),
          onSort: () => onSort('conf'),
        ),
        SailTableHeaderCell(
          child: SailText.primary12('Date'),
          onSort: () => onSort('date'),
        ),
        SailTableHeaderCell(
          child: SailText.primary12('TxID'),
          onSort: () => onSort('txid'),
        ),
        SailTableHeaderCell(
          child: SailText.primary12('Amount'),
          onSort: () => onSort('amount'),
        ),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.entries[row];
        return [
          SailTableCell(child: SailText.primary12(entry.confirmationTime.height.toString())),
          SailTableCell(child: SailText.primary12(entry.confirmationTime.timestamp.toDateTime().format())),
          SailTableCell(child: SailText.primary12(entry.txid)),
          SailTableCell(child: SailText.primary12(formatBitcoin(satoshiToBTC(entry.receivedSatoshi.toInt())))),
        ];
      },
      rowCount: widget.entries.length,
      columnCount: 4,
      columnWidths: const [100, 150, 200, 150],
      headerDecoration: BoxDecoration(
        color: context.sailTheme.colors.formFieldBorder,
      ),
      drawGrid: true,
      sortColumnIndex: ['conf', 'date', 'txid', 'amount'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['conf', 'date', 'txid', 'amount'][columnIndex]);
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
              vertical: SailStyleValues.padding15,
            ),
            child: Container(),
          ),
        ),
      );
    },
  );
}
