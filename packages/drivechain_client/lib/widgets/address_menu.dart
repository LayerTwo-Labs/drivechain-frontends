import 'package:drivechain_client/pages/send_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import 'package:drivechain_client/address_book.dart';
import 'package:sail_ui/sail_ui.dart';

class AddressMenu extends StatelessWidget {
  const AddressMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddressMenuViewModel>.reactive(
      viewModelBuilder: () => AddressMenuViewModel(),
      builder: (context, model, child) {
        return Column(
          children: [
            SailText.primary12(
              'These are your Bitcoing addresses for sending payments. Always check the amount and the receiving address before sending coins.',
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: AddressTable(
                  entries: model.entries,
                  sortColumn: model.sortColumn,
                  sortAscending: model.sortAscending,
                  onSort: model.onSort,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    QtButton(
                      onPressed: model.onNewPressed,
                      child: SailText.primary12('New'),
                    ),
                    const SizedBox(width: 8),
                    QtButton(
                      onPressed: model.onCopyPressed,
                      child: SailText.primary12('Copy'),
                    ),
                    const SizedBox(width: 8),
                    QtButton(
                      onPressed: model.onDeletePressed,
                      child: SailText.primary12('Delete'),
                    ),
                  ],
                ),
                QtButton(
                  onPressed: () => model.onChoosePressed(context),
                  child: SailText.primary12('Choose'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AddressTable extends StatelessWidget {
  final List<AddressEntry> entries;
  final String sortColumn;
  final bool sortAscending;
  final Function(String) onSort;

  const AddressTable({
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
          Theme.of(context).scaffoldBackgroundColor,
        ),
        headingRowHeight: 24.0,
        dataTextStyle: SailStyleValues.twelve,
        headingTextStyle: SailStyleValues.ten,
        dividerThickness: 0,
        dataRowMaxHeight: 48.0,
        columns: [
          DataColumn(
            label: SailText.primary12('Label'),
            onSort: (_, __) => onSort('label'),
            headingRowAlignment: MainAxisAlignment.spaceBetween,
          ),
          DataColumn(
            label: SailText.primary12('Address'),
            onSort: (_, __) => onSort('address'),
            headingRowAlignment: MainAxisAlignment.spaceBetween,
          ),
        ],
        rows: entries
            .map(
              (entry) => DataRow(
                color: WidgetStateProperty.resolveWith(
                  (states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.sailTheme.colors.primary.withOpacity(0.5);
                  }
                  return Colors.transparent;
                }),
                cells: [
                  DataCell(SailText.primary12(entry.label)),
                  DataCell(SailText.primary12(entry.address)),
                ],
              ),
            )
            .toList(),
        sortColumnIndex: sortColumn == 'label' ? 0 : 1,
        sortAscending: sortAscending,
      ),
    );
  }
}

class AddressMenuViewModel extends BaseViewModel {
  final AddressBook _addressBook = GetIt.I<AddressBook>();
  List<AddressEntry> entries = [];
  String sortColumn = 'label';
  bool sortAscending = true;

  AddressMenuViewModel() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    entries = await _addressBook.getAllEntries();
    sortEntries();
    notifyListeners();
  }

  void sortEntries() {
    entries.sort((a, b) {
      final aValue = sortColumn == 'label' ? a.label : a.address;
      final bValue = sortColumn == 'label' ? b.label : b.address;
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

  void onNewPressed() {
    // TODO: Implement new address entry logic
  }

  void onCopyPressed() {
    // TODO: Implement copy selected address logic
  }

  void onDeletePressed() {
    // TODO: Implement delete selected address logic
  }

  void onChoosePressed(BuildContext context) {
    // TODO: Implement choose address logic
    Navigator.of(context).pop(/* selected address */);
  }
}

Future<AddressEntry?> showAddressBookModal(BuildContext context) {
  return showDialog<AddressEntry>(
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
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding25,
              vertical: SailStyleValues.padding15,
            ),
            child: AddressMenu(),
          ),
        ),
      );
    },
  );
}
