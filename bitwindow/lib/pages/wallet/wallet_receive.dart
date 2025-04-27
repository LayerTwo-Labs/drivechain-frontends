import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
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
        return Column(
          children: [
            SailRow(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailCard(
                    title: 'Receive Bitcoin',
                    subtitle: 'Receive bitcoin on L1. No sidechains involved.',
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
          ],
        );
      },
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

  void init() {
    transactionsProvider.addListener(_onAddressChanged);
    _addressBookProvider.addListener(_onAddressBookChanged);
    generateNewAddress();
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
