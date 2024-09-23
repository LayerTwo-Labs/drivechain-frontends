import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/gen/wallet/v1/wallet.pb.dart';
import 'package:drivechain_client/pages/send_page.dart';
import 'package:drivechain_client/providers/transactions_provider.dart';
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
                    sortColumn: model.sortColumn,
                    sortAscending: model.sortAscending,
                    onSort: model.onSort,
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

class TransactionTable extends StatelessWidget {
  final List<Transaction> entries;
  final String sortColumn;
  final bool sortAscending;
  final Function(String) onSort;

  const TransactionTable({
    super.key,
    required this.entries,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        decoration: BoxDecoration(
          color: context.sailTheme.colors.background,
          border: Border.all(
            color: context.sailTheme.colors.formFieldBorder,
            width: 1.0,
          ),
        ),
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: context.sailTheme.colors.formFieldBorder,
            width: 1.0,
          ),
        ),
        headingRowColor: WidgetStateProperty.all(
          context.sailTheme.colors.formFieldBorder,
        ),
        // Set the sort arrow color using the theme's primary color
        columnSpacing: SailStyleValues.padding15,
        headingRowHeight: 24.0,
        dataTextStyle: SailStyleValues.twelve,
        headingTextStyle: SailStyleValues.ten,
        dividerThickness: 0,
        dataRowMaxHeight: 48.0,
        columns: [
          DataColumn(
            label: SailText.primary12('Conf'),
            onSort: (_, __) => onSort('conf'),
            headingRowAlignment: MainAxisAlignment.spaceBetween,
          ),
          DataColumn(
            label: SailText.primary12('Date'),
            onSort: (_, __) => onSort('date'),
            headingRowAlignment: MainAxisAlignment.spaceBetween,
          ),
          DataColumn(
            label: SailText.primary12('TxID'),
            onSort: (_, __) => onSort('txid'),
            headingRowAlignment: MainAxisAlignment.spaceBetween,
          ),
          DataColumn(
            label: SailText.primary12('Amount'),
            onSort: (_, __) => onSort('amount'),
            headingRowAlignment: MainAxisAlignment.spaceBetween,
          ),
        ],
        rows: entries
            .map(
              (entry) => DataRow(
                color: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.sailTheme.colors.primary.withOpacity(0.5);
                  }
                  return Colors.transparent;
                }),
                cells: [
                  DataCell(SailText.primary12(entry.confirmationTime.height.toString())),
                  DataCell(SailText.primary12(entry.confirmationTime.timestamp.toDateTime().format())),
                  DataCell(SailText.primary12(entry.txid)),
                  DataCell(SailText.primary12(formatBitcoin(satoshiToBTC(entry.receivedSatoshi.toInt())))),
                ],
              ),
            )
            .toList(),
        sortColumnIndex: ['conf', 'date', 'txid', 'amount'].indexOf(sortColumn),
        sortAscending: sortAscending,
      ),
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
    loadEntries();
    searchController.addListener(notifyListeners);
  }

  Future<void> loadEntries() async {
    sortEntries();
    notifyListeners();
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

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortEntries();
    notifyListeners();
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
