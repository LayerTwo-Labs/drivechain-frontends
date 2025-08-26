import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class AddressBookViewModel extends BaseViewModel {
  final AddressBookProvider _provider = GetIt.I.get<AddressBookProvider>();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController editLabelController = TextEditingController();

  Direction direction = Direction.DIRECTION_SEND;

  AddressBookViewModel() {
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

  void setDirection(Direction newDirection) {
    direction = newDirection;
    notifyListeners();
  }

  Future<void> createEntry() async {
    if (labelController.text.isEmpty || addressController.text.isEmpty) return;

    try {
      setBusy(true);
      setErrorForObject('create', null);
      notifyListeners();

      await _provider.createEntry(labelController.text, addressController.text, direction);
      labelController.clear();
      addressController.clear();
    } catch (e) {
      setErrorForObject('create', e.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateLabel(Int64 id) async {
    if (editLabelController.text.isEmpty) return;

    try {
      setBusy(true);
      setErrorForObject('edit', null);
      notifyListeners();

      await _provider.updateLabel(id, editLabelController.text);
      editLabelController.clear();
    } catch (e) {
      setErrorForObject('edit', e.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteEntry(Int64 id) async {
    try {
      setBusy(true);
      setErrorForObject('delete', null);
      notifyListeners();

      await _provider.deleteEntry(id);
    } catch (e) {
      setErrorForObject('delete', e.toString());
      notifyListeners();
      rethrow;
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
  const AddressBookTable({super.key});

  @override
  State<AddressBookTable> createState() => _AddressBookTableState();
}

class _AddressBookTableState extends State<AddressBookTable> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddressBookViewModel>.reactive(
      viewModelBuilder: () => AddressBookViewModel(),
      builder: (context, model, child) {
        final content = AddressBookContent(viewModel: model);

        return SailPadding(
          padding: EdgeInsets.only(
            top: SailStyleValues.padding08,
            left: SailStyleValues.padding08,
            right: SailStyleValues.padding08,
          ),
          child: InlineTabBar(
            tabs: [
              TabItem(label: 'Send', icon: SailSVGAsset.iconSend, child: content),
              TabItem(label: 'Receive', icon: SailSVGAsset.iconReceive, child: content),
            ],
            initialIndex: model.direction == Direction.DIRECTION_SEND ? 0 : 1,
            onTabChanged: (index) {
              final newDirection = index == 0 ? Direction.DIRECTION_SEND : Direction.DIRECTION_RECEIVE;
              model.setDirection(newDirection);
            },
          ),
        );
      },
    );
  }
}

class SendTableView extends ViewModelWidget<AddressBookViewModel> {
  const SendTableView({super.key});

  @override
  Widget build(BuildContext context, AddressBookViewModel viewModel) {
    return AddressBookContent(viewModel: viewModel);
  }
}

class ReceiveTableView extends ViewModelWidget<AddressBookViewModel> {
  const ReceiveTableView({super.key});

  @override
  Widget build(BuildContext context, AddressBookViewModel viewModel) {
    return AddressBookContent(viewModel: viewModel);
  }
}

class AddressBookContent extends StatefulWidget {
  final AddressBookViewModel viewModel;

  const AddressBookContent({super.key, required this.viewModel});

  @override
  State<AddressBookContent> createState() => _AddressBookContentState();
}

class _AddressBookContentState extends State<AddressBookContent> {
  String sortColumn = 'label';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.viewModel.direction;

    return SailCard(
      key: Key('address-book-$direction'),
      title: direction == Direction.DIRECTION_SEND ? 'Sending Addresses' : 'Receiving Addresses',
      subtitle: widget.viewModel.error('create') ?? widget.viewModel.error('edit') ?? widget.viewModel.error('delete'),
      widgetHeaderEnd: direction == Direction.DIRECTION_SEND
          ? Padding(
              padding: const EdgeInsets.only(bottom: SailStyleValues.padding16),
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailButton(label: 'Add New Sending Address', onPressed: () async => _showCreateDialog(context)),
                ],
              ),
            )
          : null,
      bottomPadding: false,
      child: SailTable(
        getRowId: (index) => widget.viewModel.entries[index].id.toString(),
        headerBuilder: (context) => [
          SailTableHeaderCell(name: 'Label', onSort: () => onSort('label')),
          SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
          const SailTableHeaderCell(name: 'Actions'),
        ],
        rowBuilder: (context, row, selected) {
          final entry = widget.viewModel.entries[row];

          return [
            SailTableCell(
              value: entry.label == '' ? '(no label)' : entry.label,
              monospace: true,
              italic: entry.label == '',
            ),
            SailTableCell(value: entry.address, monospace: true),
            SailTableCell(
              value: 'Actions',
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailButton(
                    label: 'Edit Label',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => _showEditDialog(context, entry),
                    insideTable: true,
                  ),
                  SailButton(
                    label: 'Delete',
                    variant: ButtonVariant.destructive,
                    onPressed: () async => _showDeleteConfirmation(context, entry),
                    insideTable: true,
                  ),
                ],
              ),
            ),
          ];
        },
        rowCount: widget.viewModel.entries.length,
        drawGrid: true,
        sortColumnIndex: ['label', 'address', 'actions'].indexOf(sortColumn),
        sortAscending: sortAscending,
        onSort: (columnIndex, ascending) {
          onSort(['label', 'address', 'actions'][columnIndex]);
        },
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
    widget.viewModel.entries.sort((a, b) {
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
    widget.viewModel.prepareEdit(entry);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SailCard(
            title: 'Edit Label',
            subtitle: '',
            withCloseButton: true,
            error: widget.viewModel.error('edit'),
            child: SailColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SailStyleValues.padding16,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailTextField(
                  label: 'Label',
                  controller: widget.viewModel.editLabelController,
                  hintText: 'Enter a new label',
                  size: TextFieldSize.small,
                ),
                SailButton(
                  label: 'Update',
                  onPressed: () async {
                    try {
                      await widget.viewModel.updateLabel(entry.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      // Error is handled by the model
                    }
                  },
                  disabled: widget.viewModel.editLabelController.text.isEmpty,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SailCard(
            title: widget.viewModel.direction == Direction.DIRECTION_SEND
                ? 'New Sending Address'
                : 'New Receiving Address',
            subtitle: '',
            withCloseButton: true,
            error: widget.viewModel.error('create'),
            child: SailColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SailStyleValues.padding16,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailTextField(
                  label: 'Address',
                  controller: widget.viewModel.addressController,
                  hintText: 'Enter a Bitcoin address',
                  size: TextFieldSize.small,
                ),
                SailTextField(
                  label: 'Label',
                  controller: widget.viewModel.labelController,
                  hintText: 'Enter a label for this address',
                  size: TextFieldSize.small,
                ),
                SailButton(
                  label: 'Create',
                  onPressed: () async {
                    await widget.viewModel.createEntry();
                    if (context.mounted) Navigator.pop(context);
                  },
                  disabled:
                      widget.viewModel.labelController.text.isEmpty || widget.viewModel.addressController.text.isEmpty,
                ),
              ],
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
          child: SailCard(
            title: 'Delete Address',
            subtitle: '',
            error: widget.viewModel.error('delete'),
            child: SailColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SailStyleValues.padding16,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.secondary13('Are you sure you want to delete "${entry.label}"?'),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Delete',
                      onPressed: () async {
                        try {
                          await widget.viewModel.deleteEntry(entry.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          // Error is handled by the model
                        }
                      },
                    ),
                    SailButton(label: 'Cancel', onPressed: () async => Navigator.pop(context)),
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
