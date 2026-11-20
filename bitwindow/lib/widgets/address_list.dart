import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';

const double actionsColumnWidth = 96;

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

  void clearError(String key) {
    setErrorForObject(key, null);
    notifyListeners();
  }

  void setDirection(Direction newDirection) {
    direction = newDirection;
    notifyListeners();
  }

  Future<void> createEntry() async {
    if (labelController.text.isEmpty || addressController.text.isEmpty) {
      return;
    }

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
    if (editLabelController.text.isEmpty) {
      return;
    }

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

  Future<void> exportLabels(BuildContext context) async {
    setErrorForObject('labels', null);
    try {
      setBusy(true);

      final jsonl = await _provider.exportLabels();
      if (jsonl.isEmpty) {
        if (context.mounted) {
          showSailToast(context, 'No labels to export');
        }
        return;
      }

      final defaultFileName = 'bitwindow-labels-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.jsonl';
      final result = await FilePicker.saveFile(
        dialogTitle: 'Export Labels (BIP329)',
        fileName: defaultFileName,
        bytes: Uint8List.fromList(utf8.encode(jsonl)),
      );
      if (result == null) {
        return;
      }

      if (context.mounted) {
        showSailToast(context, 'Labels exported to ${result.toFilePath()}');
      }
    } catch (e) {
      setErrorForObject('labels', 'Export failed: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> importLabels(BuildContext context) async {
    setErrorForObject('labels', null);
    try {
      setBusy(true);

      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['jsonl'],
        dialogTitle: 'Import Labels (BIP329)',
      );
      if (result?.path == null) {
        return;
      }

      final jsonl = await File(result!.path!).readAsString();
      final summary = await _provider.importLabels(jsonl);

      final imported = summary.importedAddresses + summary.importedTransactions + summary.importedOutputs;
      if (context.mounted) {
        showSailToast(context, 'Imported $imported labels, skipped ${summary.skipped}');
      }
    } catch (e) {
      setErrorForObject('labels', 'Import failed: $e');
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
  const AddressBookTable({
    super.key,
  });

  @override
  State<AddressBookTable> createState() => _AddressBookTableState();
}

class _AddressBookTableState extends State<AddressBookTable> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddressBookViewModel>.reactive(
      viewModelBuilder: () => AddressBookViewModel(),
      builder: (context, model, child) {
        final content = AddressBookContent(
          viewModel: model,
        );

        return SailPadding(
          padding: EdgeInsets.only(
            top: SailStyleValues.padding08,
            left: SailStyleValues.padding08,
            right: SailStyleValues.padding08,
          ),
          child: InlineTabBar(
            tabs: [
              TabItem(
                label: 'Send',
                icon: SailSVGAsset.iconSend,
                child: content,
              ),
              TabItem(
                label: 'Receive',
                icon: SailSVGAsset.iconReceive,
                child: content,
              ),
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
  const SendTableView({
    super.key,
  });

  @override
  Widget build(BuildContext context, AddressBookViewModel viewModel) {
    return AddressBookContent(
      viewModel: viewModel,
    );
  }
}

class ReceiveTableView extends ViewModelWidget<AddressBookViewModel> {
  const ReceiveTableView({
    super.key,
  });

  @override
  Widget build(BuildContext context, AddressBookViewModel viewModel) {
    return AddressBookContent(
      viewModel: viewModel,
    );
  }
}

class AddressBookContent extends StatefulWidget {
  final AddressBookViewModel viewModel;

  const AddressBookContent({
    super.key,
    required this.viewModel,
  });

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

  List<AddressBookEntry> get _sortedEntries {
    final entries = [...widget.viewModel.entries];
    String key(AddressBookEntry e) => sortColumn == 'address' ? e.address : e.label;
    entries.sort((a, b) => sortAscending ? key(a).compareTo(key(b)) : key(b).compareTo(key(a)));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.viewModel.direction;
    final entries = _sortedEntries;
    final phone = SailStyleValues.phoneLayout(context);
    final buttons = SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        if (direction == Direction.DIRECTION_SEND)
          SailButton(
            label: 'Add Address',
            onPressed: () async => unawaited(_showCreateDialog(context)),
          ),
        SailButton(
          label: 'Import',
          variant: ButtonVariant.outline,
          onPressed: () async => widget.viewModel.importLabels(context),
        ),
        SailButton(
          label: 'Export',
          variant: ButtonVariant.outline,
          onPressed: () async => widget.viewModel.exportLabels(context),
        ),
      ],
    );

    return SailCard(
      key: Key('address-book-$direction'),
      title: direction == Direction.DIRECTION_SEND ? 'Sending Addresses' : 'Receiving Addresses',
      subtitle: widget.viewModel.error('create') ?? widget.viewModel.error('edit') ?? widget.viewModel.error('delete'),
      error: widget.viewModel.error('labels')?.toString(),
      widgetHeaderEnd: phone ? null : buttons,
      bottomPadding: false,
      child: phone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buttons,
                const SizedBox(height: SailStyleValues.padding08),
                Flexible(
                  child: _PhoneAddressList(
                    entries: entries,
                    onEdit: (entry) => _showEditDialog(context, entry),
                    onDelete: (entry) => _showDeleteConfirmation(context, entry),
                  ),
                ),
              ],
            )
          : SailTable(
              getRowId: (index) => entries[index].id.toString(),
              headerBuilder: (context) => [
                const SailTableHeaderCell(name: 'Label'),
                const SailTableHeaderCell(name: 'Address'),
                const SailTableHeaderCell(
                  name: 'Actions',
                  alignment: Alignment.centerRight,
                  sortable: false,
                ),
              ],
              rowBuilder: (context, row, selected) {
                final entry = entries[row];

                return [
                  SailTableCell(
                    value: entry.label == '' ? '(no label)' : entry.label,
                    monospace: true,
                    italic: entry.label == '',
                  ),
                  SailTableCell(
                    value: entry.address,
                    copyValue: entry.address,
                    monospace: true,
                  ),
                  SailTableCell(
                    value: 'Actions',
                    width: actionsColumnWidth,
                    alignment: Alignment.centerRight,
                    child: SailRow(
                      spacing: SailStyleValues.padding04,
                      children: [
                        SailTooltip(
                          message: 'Edit label',
                          child: SailButton(
                            variant: ButtonVariant.icon,
                            icon: SailSVGAsset.iconPen,
                            onPressed: () async => unawaited(_showEditDialog(context, entry)),
                            insideTable: true,
                          ),
                        ),
                        SailTooltip(
                          message: 'Delete address',
                          child: SailButton(
                            variant: ButtonVariant.icon,
                            icon: SailSVGAsset.iconDelete,
                            onPressed: () async => unawaited(_showDeleteConfirmation(context, entry)),
                            insideTable: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              rowCount: entries.length,
              emptyPlaceholder: 'No addresses yet',
              drawGrid: true,
              sortColumnIndex: ['label', 'address'].indexOf(sortColumn),
              sortAscending: sortAscending,
              onSort: (columnIndex, ascending) => setState(() {
                sortColumn = ['label', 'address'][columnIndex];
                sortAscending = ascending;
              }),
            ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, AddressBookEntry entry) async {
    widget.viewModel.prepareEdit(entry);
    await showThemedDialog(
      context: context,
      builder: (context) => _EditDialog(
        viewModel: widget.viewModel,
        entry: entry,
      ),
    );
    if (mounted) {
      widget.viewModel.clearError('edit');
    }
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (context) => _CreateDialog(viewModel: widget.viewModel),
    );
    if (mounted) {
      widget.viewModel.clearError('create');
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, AddressBookEntry entry) async {
    await showThemedDialog(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => SailModal(
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
    );
    if (mounted) {
      widget.viewModel.clearError('delete');
    }
  }
}

class _PhoneAddressList extends StatelessWidget {
  final List<AddressBookEntry> entries;
  final Future<void> Function(AddressBookEntry entry) onEdit;
  final Future<void> Function(AddressBookEntry entry) onDelete;

  const _PhoneAddressList({required this.entries, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding16),
        child: SailText.secondary13('No addresses yet'),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: entries.length,
      separatorBuilder: (context, index) => Container(height: 1, color: theme.colors.divider),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailText.primary13(
                      entry.label == '' ? '(no label)' : entry.label,
                      bold: true,
                      italic: entry.label == '',
                    ),
                    const SizedBox(height: 2),
                    SailText.secondary12(entry.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: SailStyleValues.padding08),
              SailButton(
                variant: ButtonVariant.icon,
                icon: SailSVGAsset.iconPen,
                onPressed: () async => unawaited(onEdit(entry)),
              ),
              SailButton(
                variant: ButtonVariant.icon,
                icon: SailSVGAsset.iconDelete,
                onPressed: () async => unawaited(onDelete(entry)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CreateDialog extends StatelessWidget {
  final AddressBookViewModel viewModel;

  const _CreateDialog({
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => SailModal(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SailCard(
          title: viewModel.direction == Direction.DIRECTION_SEND ? 'New Sending Address' : 'New Receiving Address',
          subtitle: '',
          withCloseButton: true,
          error: viewModel.error('create'),
          child: SailColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.min,
            children: [
              SailTextField(
                label: 'Address',
                controller: viewModel.addressController,
                hintText: 'Enter a Bitcoin address',
                size: TextFieldSize.small,
              ),
              SailTextField(
                label: 'Label',
                controller: viewModel.labelController,
                hintText: 'Enter a label for this address',
                size: TextFieldSize.small,
              ),
              SailButton(
                label: 'Create',
                onPressed: () async {
                  try {
                    await viewModel.createEntry();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    // Error is handled by the model
                  }
                },
                disabled: viewModel.labelController.text.isEmpty || viewModel.addressController.text.isEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditDialog extends StatelessWidget {
  final AddressBookViewModel viewModel;
  final AddressBookEntry entry;

  const _EditDialog({
    required this.viewModel,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => SailModal(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SailCard(
          title: 'Edit Label',
          subtitle: '',
          withCloseButton: true,
          error: viewModel.error('edit'),
          child: SailColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.min,
            children: [
              SailTextField(
                label: 'Label',
                controller: viewModel.editLabelController,
                hintText: 'Enter a new label',
                size: TextFieldSize.small,
              ),
              SailButton(
                label: 'Update',
                onPressed: () async {
                  try {
                    await viewModel.updateLabel(entry.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    // Error is handled by the model
                  }
                },
                disabled: viewModel.editLabelController.text.isEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
