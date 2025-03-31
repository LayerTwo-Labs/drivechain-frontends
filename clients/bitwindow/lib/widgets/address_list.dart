import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class AddressBookViewModel extends BaseViewModel {
  final AddressBookProvider _provider = GetIt.I.get<AddressBookProvider>();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController editLabelController = TextEditingController();

  Direction direction = Direction.DIRECTION_SEND;

  AddressBookViewModel(Direction? initialDirection) {
    direction = initialDirection ?? Direction.DIRECTION_SEND;
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
  final Direction? initialDirection;

  const AddressBookTable({
    super.key,
    this.initialDirection,
  });

  @override
  State<AddressBookTable> createState() => _AddressBookTableState();
}

class _AddressBookTableState extends State<AddressBookTable> {
  late final AddressBookViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddressBookViewModel(widget.initialDirection);

    if (widget.initialDirection == null) {
    } else {}
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
      builder: (context, model, child) {
        if (widget.initialDirection == null) {
          return SailPadding(
            padding: EdgeInsets.only(
              top: SailStyleValues.padding16,
              left: SailStyleValues.padding16,
              right: SailStyleValues.padding16,
              bottom: SailStyleValues.padding64 * 2,
            ),
            child: SailRawCard(
              withCloseButton: true,
              color: context.sailTheme.colors.background,
              child: InlineTabBar(
                tabs: [
                  TabItem(
                    label: 'Send',
                    icon: SailSVGAsset.iconSend,
                    child: AddressBookContent(
                      key: Key('send'),
                      direction: Direction.DIRECTION_SEND,
                      viewModel: model,
                    ),
                  ),
                  TabItem(
                    label: 'Receive',
                    icon: SailSVGAsset.iconReceive,
                    child: AddressBookContent(
                      key: Key('receive'),
                      direction: Direction.DIRECTION_RECEIVE,
                      viewModel: model,
                    ),
                  ),
                ],
                initialIndex: 0,
                onTabChanged: (index) => model.setDirection(
                  index == 0 ? Direction.DIRECTION_SEND : Direction.DIRECTION_RECEIVE,
                ),
              ),
            ),
          );
        }

        return AddressBookContent(
          direction: widget.initialDirection!,
          viewModel: model,
        );
      },
    );
  }
}

class AddressBookContent extends StatefulWidget {
  final Direction direction;
  final AddressBookViewModel viewModel;

  const AddressBookContent({
    super.key,
    required this.direction,
    required this.viewModel,
  });

  @override
  State<AddressBookContent> createState() => _AddressBookContentState();
}

class _AddressBookContentState extends State<AddressBookContent> {
  String sortColumn = 'label';
  bool sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return SailRawCard(
      title: widget.direction == Direction.DIRECTION_SEND ? 'Sending Addresses' : 'Receiving Addresses',
      subtitle: widget.viewModel.error('create') ??
          widget.viewModel.error('edit') ??
          widget.viewModel.error('delete') ??
          'Manage your addresses.',
      widgetHeaderEnd: widget.direction == Direction.DIRECTION_SEND
          ? Padding(
              padding: const EdgeInsets.only(bottom: SailStyleValues.padding16),
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailButton(
                    label: 'Create New Sending Address',
                    onPressed: () async => _showCreateDialog(context),
                  ),
                ],
              ),
            )
          : null,
      bottomPadding: false,
      child: Column(
        children: [
          Expanded(
            child: SailTable(
              getRowId: (index) => widget.viewModel.entries[index].id.toString(),
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
                final entry = widget.viewModel.entries[row];

                return [
                  SailTableCell(
                    value: entry.label == '' ? '(no label)' : entry.label,
                    monospace: true,
                    italic: entry.label == '',
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
                        SailButton(
                          label: 'Edit Label',
                          onPressed: () async => _showEditDialog(context, entry),
                        ),
                        SailButton(
                          label: 'Delete',
                          onPressed: () async => _showDeleteConfirmation(context, entry),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              rowCount: widget.viewModel.entries.length,
              columnWidths: const [100, 200, 100],
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
    final dialogViewModel = AddressBookViewModel(widget.viewModel.direction);
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
              error: model.error('edit'),
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
                  SailButton(
                    label: 'Save',
                    onPressed: () async {
                      try {
                        await model.updateLabel(entry.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          widget.viewModel.notifyListeners();
                        }
                      } catch (e) {
                        // Error is handled by the model
                      }
                    },
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
    final dialogViewModel = AddressBookViewModel(widget.viewModel.direction);

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
              withCloseButton: true,
              error: model.error('create'),
              child: SailColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: SailStyleValues.padding16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailTextField(
                    label: 'Address',
                    controller: model.addressController,
                    hintText: 'Enter a Bitcoin address',
                    size: TextFieldSize.small,
                  ),
                  SailTextField(
                    label: 'Label',
                    controller: model.labelController,
                    hintText: 'Enter a label for this address',
                    size: TextFieldSize.small,
                  ),
                  SailButton(
                    label: 'Create',
                    onPressed: () async {
                      await model.createEntry();
                      if (context.mounted) Navigator.pop(context);
                    },
                    disabled: model.labelController.text.isEmpty || model.addressController.text.isEmpty,
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
    final dialogViewModel = AddressBookViewModel(widget.viewModel.direction);

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
              title: 'Delete Address',
              subtitle: '',
              error: model.error('delete'),
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
                            await model.deleteEntry(entry.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              widget.viewModel.notifyListeners();
                            }
                          } catch (e) {
                            // Error is handled by the model
                          }
                        },
                      ),
                      SailButton(
                        label: 'Cancel',
                        onPressed: () async => Navigator.pop(context),
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
}
