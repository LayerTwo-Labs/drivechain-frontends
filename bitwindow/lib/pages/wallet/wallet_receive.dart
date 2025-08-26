import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
                                  loading: LoadingDetails(
                                    enabled: model.address.isEmpty,
                                    description: 'Waiting for enforcer to start and wallet to sync..',
                                  ),
                                  controller: TextEditingController(text: model.address),
                                  hintText: 'A Drivechain address',
                                  readOnly: true,
                                  suffixWidget: CopyButton(text: model.address),
                                ),
                              ),
                            ],
                          ),
                          if (model.address.isEmpty)
                            SailButton(label: 'Generate new address', onPressed: model.generateNewAddress),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 128,
                    child: SailCard(
                      padding: true,
                      child: QrImageView(
                        padding: EdgeInsets.zero,
                        eyeStyle: QrEyeStyle(color: theme.colors.text, eyeShape: QrEyeShape.square),
                        dataModuleStyle: QrDataModuleStyle(color: theme.colors.text),
                        data: model.address,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                ],
              ),
              ReceiveAddressesTable(model: model),
            ],
          ),
        );
      },
    );
  }
}

class ReceiveAddressesTable extends StatefulWidget {
  final ReceivePageViewModel model;

  const ReceiveAddressesTable({super.key, required this.model});

  @override
  State<ReceiveAddressesTable> createState() => _ReceiveAddressesTableState();
}

class _ReceiveAddressesTableState extends State<ReceiveAddressesTable> {
  String sortColumn = 'last_used_at';
  bool sortAscending = false;

  List<ReceiveAddress> get sortedEntries {
    final entries = List<ReceiveAddress>.from(widget.model.receiveAddresses);
    entries.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'last_used_at':
          if (a.lastUsedAt.seconds == 0 && b.lastUsedAt.seconds == 0) {
            return sortAscending ? a.address.compareTo(b.address) : b.address.compareTo(a.address);
          } else if (a.lastUsedAt.seconds == 0) {
            return sortAscending ? 1 : -1;
          } else if (b.lastUsedAt.seconds == 0) {
            return sortAscending ? -1 : 1;
          }
          aValue = a.lastUsedAt.toDateTime();
          bValue = b.lastUsedAt.toDateTime();
          int cmp = aValue.compareTo(bValue);
          if (cmp == 0) {
            return sortAscending ? a.address.compareTo(b.address) : b.address.compareTo(a.address);
          }
          return sortAscending ? cmp : -cmp;
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
    return entries;
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = sortedEntries;
    return SailCard(
      title: 'Receive Addresses',
      bottomPadding: false,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to start and wallet to sync..',
              enabled: widget.model.receiveAddresses.isEmpty,
              child: SailTable(
                getRowId: (index) => entries[index].address,
                headerBuilder: (context) => [
                  SailTableHeaderCell(name: 'Last Used', onSort: () => onSort('last_used_at')),
                  SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                  SailTableHeaderCell(name: 'Label', onSort: () => onSort('label')),
                  SailTableHeaderCell(name: 'Balance', onSort: () => onSort('current_balance_sat')),
                ],
                rowBuilder: (context, row, selected) {
                  final utxo = entries[row];
                  final formattedAmount = formatBitcoin(satoshiToBTC(utxo.currentBalanceSat.toInt()), symbol: '');
                  return [
                    SailTableCell(
                      value: utxo.lastUsedAt.seconds == 0
                          ? 'Never'
                          : formatDate(utxo.lastUsedAt.toDateTime().toLocal()),
                    ),
                    SailTableCell(value: utxo.address),
                    SailTableCell(value: utxo.label),
                    SailTableCell(value: formattedAmount, monospace: true),
                  ];
                },
                rowCount: entries.length,
                drawGrid: true,
                sortColumnIndex: ['last_used_at', 'address', 'label', 'current_balance_sat'].indexOf(sortColumn),
                sortAscending: sortAscending,
                onSort: (columnIndex, ascending) {
                  onSort(['last_used_at', 'address', 'label', 'current_balance_sat'][columnIndex]);
                },
                contextMenuItems: (rowId) {
                  final entry = entries.firstWhere((e) => e.address == rowId);

                  return [
                    SailMenuItem(
                      closeOnSelect: false,
                      onSelected: () async {
                        await Future.microtask(() async {
                          if (!context.mounted) return;
                          await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 400),
                                child: SailCardEditValues(
                                  title: entry.label.isEmpty ? 'Add Label' : 'Edit Label',
                                  subtitle:
                                      "${entry.label.isEmpty ? "Set a" : "Update the"} label and click Save when you're done",
                                  fields: [EditField(name: 'Label', currentValue: entry.label)],
                                  onSave: (updatedFields) async {
                                    final newLabel = updatedFields.firstWhere((f) => f.name == 'Label').currentValue;
                                    await widget.model.saveLabel(context, entry.address, newLabel);
                                  },
                                ),
                              ),
                            ),
                          );
                        });
                      },
                      child: SailText.primary12(entry.label.isEmpty ? 'Add Label' : 'Update Label'),
                    ),
                  ];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReceivePageViewModel extends BaseViewModel {
  final AddressBookProvider _addressBookProvider = GetIt.I<AddressBookProvider>();
  final BitwindowRPC _bitwindowRPC = GetIt.I<BitwindowRPC>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();

  @override
  String? modelError;

  String get address => transactionsProvider.address;
  List<ReceiveAddress> get receiveAddresses => transactionsProvider.receiveAddresses.toList();

  AddressBookEntry get matchingEntry => _addressBookProvider.receiveEntries.firstWhere(
    (e) => e.address == address,
    orElse: () => AddressBookEntry(id: Int64(0), label: '', address: '', direction: Direction.DIRECTION_RECEIVE),
  );
  bool get hasExistingLabel => matchingEntry.label.isNotEmpty;

  String sortColumn = 'address';
  bool sortAscending = true;

  void init() {
    // bitwindowrpc has a health stream that notifies listener. when it changes, we should try to
    // regenerate an address!
    _bitwindowRPC.addListener(generateNewAddress);
    transactionsProvider.addListener(notifyListeners);
    _addressBookProvider.addListener(notifyListeners);
    generateNewAddress();
  }

  @override
  void dispose() {
    transactionsProvider.removeListener(notifyListeners);
    _addressBookProvider.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> generateNewAddress() async {
    try {
      modelError = null;
      await transactionsProvider.fetch();
    } catch (e) {
      if (e.toString() != modelError) {
        modelError = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> saveLabel(BuildContext context, String address, String label) async {
    try {
      modelError = null;
      setBusy(true);
      await _addressBookProvider.createEntry(label, address, Direction.DIRECTION_RECEIVE);

      // Fetch the transactions provider to update the receiveAddresses list
      await transactionsProvider.fetch();

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (error.toString() != modelError) {
        modelError = error.toString();
        notifyListeners();
      }
    } finally {
      setBusy(false);
    }
  }
}
