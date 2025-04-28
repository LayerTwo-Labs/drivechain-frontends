import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ReceiveTab extends StatelessWidget {
  const ReceiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ReceivePageViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return SingleChildScrollView(
          child: SailColumn(
            spacing: 16,
            children: [
              SailRow(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailCard(
                      title: 'Receive Bitcoin on L1',
                      error: model.modelError,
                      child: SailColumn(
                        spacing: SailStyleValues.padding16,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            children: [
                              Expanded(
                                child: SailTextField(
                                  controller: TextEditingController(text: model.address),
                                  hintText: 'A Drivechain address',
                                  readOnly: true,
                                  suffixWidget: CopyButton(
                                    text: model.address,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: SailTextField(
                                  label: 'Label (optional)',
                                  controller: model.labelController,
                                  hintText: '',
                                  size: TextFieldSize.small,
                                  helperText:
                                      'Save this receive address to your address book with the label you type here',
                                ),
                              ),
                              SailButton(
                                label: model.hasExistingLabel ? 'Update Label' : 'Set Label',
                                onPressed: () async {
                                  try {
                                    if (model.hasExistingLabel) {
                                      await model.updateLabel(model.matchingEntry.id);
                                    } else {
                                      await model.saveLabel(context);
                                    }
                                  } catch (e) {
                                    // Error handled by model
                                  }
                                },
                                disabled: model.isBusy || !model.hasLabelChanged,
                              ),
                            ],
                          ),
                          if (model.address.isEmpty)
                            SailButton(
                              label: 'Generate new address',
                              onPressed: model.generateNewAddress,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: SailCard(
                      padding: true,
                      child: QrImageView(
                        padding: EdgeInsets.zero,
                        eyeStyle: QrEyeStyle(
                          color: theme.colors.text,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: QrDataModuleStyle(color: theme.colors.text),
                        data: model.address,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                ],
              ),
              ReceiveAddressesTable(
                entries: model.receiveAddresses,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReceiveAddressesTable extends StatefulWidget {
  final List<ReceiveAddress> entries;

  const ReceiveAddressesTable({super.key, required this.entries});

  @override
  State<ReceiveAddressesTable> createState() => _ReceiveAddressesTableState();
}

class _ReceiveAddressesTableState extends State<ReceiveAddressesTable> {
  String sortColumn = 'address';
  bool sortAscending = true;
  late List<ReceiveAddress> entries;

  @override
  void initState() {
    super.initState();
    entries = List.from(widget.entries);
    sortEntries();
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
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'label':
          aValue = a.label;
          bValue = b.label;
          break;
        case 'current_balance_sat':
          aValue = a.currentBalanceSat;
          bValue = b.currentBalanceSat;
          break;
      }
      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Receive Addresses',
      bottomPadding: false,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: SailTable(
              getRowId: (index) => entries[index].address,
              headerBuilder: (context) => [
                SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                SailTableHeaderCell(name: 'Label', onSort: () => onSort('label')),
                SailTableHeaderCell(name: 'Balance', onSort: () => onSort('current_balance_sat')),
              ],
              rowBuilder: (context, row, selected) {
                final utxo = entries[row];
                final formattedAmount = formatBitcoin(
                  satoshiToBTC(utxo.currentBalanceSat.toInt()),
                  symbol: '',
                );
                return [
                  SailTableCell(value: utxo.address),
                  SailTableCell(value: utxo.label),
                  SailTableCell(value: formattedAmount, monospace: true),
                ];
              },
              rowCount: entries.length,
              columnWidths: const [200, 100, 50],
              drawGrid: true,
              sortColumnIndex: [
                'address',
                'label',
                'current_balance_sat',
              ].indexOf(sortColumn),
              sortAscending: sortAscending,
              onSort: (columnIndex, ascending) {
                onSort(['address', 'label', 'current_balance_sat'][columnIndex]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReceivePageViewModel extends BaseViewModel {
  final AddressBookProvider _addressBookProvider = GetIt.I<AddressBookProvider>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();
  final TextEditingController labelController = TextEditingController();

  String get address => transactionsProvider.address;

  AddressBookEntry get matchingEntry => _addressBookProvider.receiveEntries.firstWhere(
        (e) => e.address == address,
        orElse: () => AddressBookEntry(id: Int64(0), label: '', address: '', direction: Direction.DIRECTION_RECEIVE),
      );
  bool get hasExistingLabel => matchingEntry.label.isNotEmpty;
  bool get hasLabelChanged => labelController.text != matchingEntry.label;

  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  List<ReceiveAddress> get receiveAddresses => _txProvider.receiveAddresses.toList();

  String sortColumn = 'address';
  bool sortAscending = true;

  void init() {
    transactionsProvider.addListener(_onAddressChanged);
    _addressBookProvider.addListener(_onAddressBookChanged);
    _txProvider.addListener(notifyListeners);
    generateNewAddress();
    _txProvider.fetch();

    labelController.addListener(notifyListeners);
  }

  void _onAddressChanged() {
    if (labelController.text.isEmpty) {
      labelController.text = matchingEntry.label;
    }
    notifyListeners();
  }

  void _onAddressBookChanged() {
    // When address book changes, update label if this address exists
    _onAddressChanged();
  }

  @override
  void dispose() {
    transactionsProvider.removeListener(_onAddressChanged);
    _addressBookProvider.removeListener(_onAddressBookChanged);
    labelController.removeListener(notifyListeners);
    labelController.dispose();
    _txProvider.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> generateNewAddress() async {
    await transactionsProvider.fetch();
  }

  Future<void> saveLabel(BuildContext context) async {
    try {
      setBusy(true);
      setErrorForObject('create', null);
      notifyListeners();

      await _addressBookProvider.createEntry(
        labelController.text,
        address,
        Direction.DIRECTION_RECEIVE,
      );

      labelController.clear();
      await _addressBookProvider.fetch();
      if (context.mounted) {
        showSnackBar(context, 'Saved New Label');
      }
    } catch (error) {
      setErrorForObject('create', error.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateLabel(Int64 id) async {
    try {
      setBusy(true);
      setErrorForObject('edit', null);
      notifyListeners();

      await _addressBookProvider.updateLabel(id, labelController.text);
      labelController.clear();
    } catch (error) {
      setErrorForObject('edit', error.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteLabel(Int64 id) async {
    try {
      setBusy(true);
      setErrorForObject('delete', null);
      notifyListeners();

      await _addressBookProvider.deleteEntry(id);
    } catch (error) {
      setErrorForObject('delete', error.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }
}
