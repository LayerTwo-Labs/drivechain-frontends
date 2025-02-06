import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class AddressBookViewModel extends BaseViewModel {
  final AddressBookProvider _provider = GetIt.I.get<AddressBookProvider>();
  final Direction direction;
  final TextEditingController labelController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController editLabelController = TextEditingController();

  AddressBookViewModel(this.direction) {
    _provider.addListener(notifyListeners);
    labelController.addListener(notifyListeners);
    addressController.addListener(notifyListeners);
    editLabelController.addListener(notifyListeners);
  }

  List<AddressBookEntry> get entries =>
      direction == Direction.DIRECTION_SEND ? _provider.sendEntries : _provider.receiveEntries;

  void prepareEdit(AddressBookEntry entry) {
    editLabelController.text = entry.label;
  }

  Future<void> createEntry() async {
    if (labelController.text.isEmpty || addressController.text.isEmpty) return;

    setBusy(true);
    try {
      await _provider.createEntry(labelController.text, addressController.text, direction);
      setError(null);
      labelController.clear();
      addressController.clear();
      await _provider.fetch();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateLabel(Int64 id) async {
    if (editLabelController.text.isEmpty) return;

    setBusy(true);
    try {
      await _provider.updateLabel(id, editLabelController.text);
      setError(null);
      editLabelController.clear();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteEntry(Int64 id) async {
    setBusy(true);
    try {
      await _provider.deleteEntry(id);
      setError(null);
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    _provider.removeListener(notifyListeners);
    labelController.removeListener(notifyListeners);
    addressController.removeListener(notifyListeners);
    editLabelController.removeListener(notifyListeners);
    labelController.dispose();
    addressController.dispose();
    editLabelController.dispose();
    super.dispose();
  }
}

class AddressBookTable extends StatefulWidget {
  final Direction direction;

  const AddressBookTable({
    super.key,
    required this.direction,
  });

  @override
  State<AddressBookTable> createState() => _AddressBookTableState();
}

class _AddressBookTableState extends State<AddressBookTable> {
  late final AddressBookViewModel _viewModel;
  String sortColumn = 'label';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    _viewModel = AddressBookViewModel(widget.direction);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddressBookViewModel>.reactive(
      viewModelBuilder: () => _viewModel,
      builder: (context, model, child) => SailRawCard(
        title: widget.direction == Direction.DIRECTION_SEND ? 'Sending Addresses' : 'Receiving Addresses',
        subtitle: model.hasError ? model.error.toString() : 'Manage your addresses.',
        widgetHeaderEnd: Padding(
          padding: const EdgeInsets.only(bottom: SailStyleValues.padding16),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              QtButton(
                label: 'Create New',
                onPressed: () => _showCreateDialog(context),
                size: ButtonSize.small,
              ),
            ],
          ),
        ),
        bottomPadding: false,
        child: Column(
          children: [
            Expanded(
              child: SailTable(
                getRowId: (index) => model.entries[index].id.toString(),
                headerBuilder: (context) => [
                  SailTableHeaderCell(
                    name: 'Label',
                    onSort: () => onSort('label'),
                  ),
                  SailTableHeaderCell(
                    name: 'Address',
                    onSort: () => onSort('address'),
                  ),
                  const SailTableHeaderCell(name: 'Actions'),
                ],
                rowBuilder: (context, row, selected) {
                  final entry = model.entries[row];

                  return [
                    SailTableCell(
                      value: entry.label,
                      monospace: true,
                    ),
                    SailTableCell(
                      value: entry.address,
                      monospace: true,
                    ),
                    SailTableCell(
                      value: 'Actions',
                      child: SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          QtButton(
                            label: 'Edit',
                            onPressed: () => _showEditDialog(context, entry),
                            size: ButtonSize.small,
                          ),
                          QtButton(
                            label: 'Delete',
                            onPressed: () => _showDeleteConfirmation(context, entry),
                            size: ButtonSize.small,
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                rowCount: model.entries.length,
                columnWidths: const [200, 300, 100],
                drawGrid: true,
                sortColumnIndex: ['label', 'address', 'actions'].indexOf(sortColumn),
                sortAscending: sortAscending,
                onSort: (columnIndex, ascending) {
                  onSort(['label', 'address', 'actions'][columnIndex]);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
    _viewModel.entries.sort((a, b) {
      switch (sortColumn) {
        case 'label':
          return sortAscending ? a.label.compareTo(b.label) : b.label.compareTo(a.label);
        case 'address':
          return sortAscending ? a.address.compareTo(b.address) : b.address.compareTo(a.address);
        default:
          return 0;
      }
    });
  }

  void _showEditDialog(BuildContext context, AddressBookEntry entry) {
    final dialogViewModel = AddressBookViewModel(widget.direction);
    dialogViewModel.prepareEdit(entry);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ViewModelBuilder<AddressBookViewModel>.reactive(
            viewModelBuilder: () => dialogViewModel,
            disposeViewModel: true,
            builder: (context, model, child) => SailRawCard(
              title: 'Edit Label',
              subtitle: '',
              child: SailColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: SailStyleValues.padding16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailTextField(
                    label: 'Label',
                    controller: model.editLabelController,
                    hintText: 'Enter a label to remember this address by',
                    size: TextFieldSize.small,
                  ),
                  QtButton(
                    label: 'Save',
                    onPressed: () async {
                      await model.updateLabel(entry.id);
                      if (context.mounted) Navigator.pop(context);
                      _viewModel.notifyListeners();
                    },
                    size: ButtonSize.small,
                    disabled: model.editLabelController.text.isEmpty,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final dialogViewModel = AddressBookViewModel(widget.direction);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ViewModelBuilder<AddressBookViewModel>.reactive(
            viewModelBuilder: () => dialogViewModel,
            disposeViewModel: true,
            builder: (context, model, child) => SailRawCard(
              title: widget.direction == Direction.DIRECTION_SEND ? 'New Sending Address' : 'New Receiving Address',
              subtitle: '',
              child: SailColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: SailStyleValues.padding16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailTextField(
                    label: 'Label',
                    controller: model.labelController,
                    hintText: 'Enter a label for this address',
                    size: TextFieldSize.small,
                  ),
                  SailTextField(
                    label: 'Address',
                    controller: model.addressController,
                    hintText: 'Enter a Bitcoin address',
                    size: TextFieldSize.small,
                  ),
                  Row(
                    children: [
                      QtButton(
                        label: 'Create',
                        onPressed: () async {
                          await model.createEntry();
                          if (context.mounted) Navigator.pop(context);
                          _viewModel.notifyListeners();
                        },
                        size: ButtonSize.small,
                        disabled: model.labelController.text.isEmpty || model.addressController.text.isEmpty,
                      ),
                      QtButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AddressBookEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SailRawCard(
            title: 'Delete Address',
            subtitle: '',
            child: SailColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SailStyleValues.padding16,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.secondary13('Are you sure you want to delete "${entry.label}"?'),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    QtButton(
                      label: 'Delete',
                      onPressed: () {
                        _viewModel.deleteEntry(entry.id);
                        Navigator.pop(context);
                      },
                      size: ButtonSize.small,
                    ),
                    QtButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      size: ButtonSize.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
