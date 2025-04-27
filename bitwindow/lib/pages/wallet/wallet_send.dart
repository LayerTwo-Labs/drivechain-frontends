import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class SendTab extends ViewModelWidget<SendPageViewModel> {
  const SendTab({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SailCard(
      title: 'Send Bitcoin',
      subtitle: 'Send bitcoin to bitcoin-addresses. No sidechains involved.',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: SailTextField(
                  label: 'Pay To',
                  controller: viewModel.addressController,
                  hintText: 'Enter a L1 bitcoin-address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
                  size: TextFieldSize.small,
                  suffixWidget: PasteButton(
                    onPaste: (text) {
                      viewModel.addressController.text = text;
                    },
                  ),
                ),
              ),
              Flexible(
                child: SailDropdownButton<AddressBookEntry>(
                  value: null,
                  hint: SailText.primary13(viewModel.selectedEntry?.label ?? 'Address Book'),
                  items: viewModel.addressBookEntries.map((entry) {
                    return SailDropdownItem<AddressBookEntry>(
                      value: entry,
                      label: entry.label,
                    );
                  }).toList(),
                  onChanged: viewModel.onAddressSelected,
                ),
              ),
              const SizedBox(width: 4.0),
            ],
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SailRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: SailStyleValues.padding08,
                      children: [
                        Expanded(
                          child: NumericField(
                            label: 'Amount',
                            controller: viewModel.amountController,
                            suffixWidget: SailButton(
                              label: 'MAX',
                              variant: ButtonVariant.link,
                              onPressed: viewModel.onUseAvailableBalance,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            UnitDropdown(
                              value: viewModel.unit,
                              onChanged: viewModel.onUnitChanged,
                              enabled: false,
                            ),
                            SailCheckbox(
                              value: viewModel.subtractFee,
                              onChanged: viewModel.onSubtractFeeChanged,
                              label: 'Subtract fee from amount',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: SailStyleValues.padding16),
                    SailTextField(
                      label: 'Label (optional)',
                      controller: viewModel.labelController,
                      hintText: 'Enter a label',
                      size: TextFieldSize.small,
                      helperText: 'If set, this address will be saved to your address book',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailButton(
                label: 'Send',
                onPressed: () => viewModel.sendTransaction(context),
              ),
              const SizedBox(width: SailStyleValues.padding08),
              SailButton(
                variant: ButtonVariant.secondary,
                label: 'Clear All',
                onPressed: viewModel.clearAll,
              ),
            ],
          ),
          // Balance
        ],
      ),
    );
  }
}

class SendPageViewModel extends BaseViewModel {
  BalanceProvider get balanceProvider => GetIt.I<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I<BlockchainProvider>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();
  AddressBookProvider get addressBookProvider => GetIt.I<AddressBookProvider>();
  BitwindowRPC get api => GetIt.I<BitwindowRPC>();
  Logger get log => GetIt.I<Logger>();
  late TextEditingController addressController;
  late TextEditingController amountController;
  late TextEditingController customFeeController;
  late TextEditingController labelController;
  Unit unit = Unit.BTC;
  bool subtractFee = false;
  String feeType = 'recommended';
  int confirmationTarget = 2;
  bool useMinimumFee = false;
  Unit feeUnit = Unit.BTC;
  EstimateSmartFeeResponse feeEstimate = EstimateSmartFeeResponse();
  List<AddressBookEntry> get addressBookEntries => addressBookProvider.sendEntries;
  AddressBookEntry? selectedEntry;
  SendPageViewModel() {
    addressController = TextEditingController(text: '');
    addressController.addListener(decodeURI);
    amountController = TextEditingController(text: '0.00');
    customFeeController = TextEditingController(text: '');
    labelController = TextEditingController(text: '');
    fetchEstimate();
    addressBookProvider.addListener(notifyListeners);
    init();
  }

  Future<void> init() async {
    applicationDir = await Environment.datadir();
    logFile = await getLogFile();
    await fetchEstimate();

    // Add listener for address changes
    addressController.addListener(_onAddressChanged);
    addressBookProvider.addListener(_onAddressBookChanged);
  }

  Directory? applicationDir;
  File? logFile;

  void decodeURI() {
    try {
      if (addressController.text.isNotEmpty) {
        final uri = Uri.parse(addressController.text);
        if (uri.scheme == 'bitcoin') {
          handleBitcoinURI(BitcoinURI.parse(uri.toString()));
        }
      }
    } catch (e) {
      // do nothing, it's okay!
    }
  }

  // Amount of blocks to confirm the transaction in
  List<int> get confirmationTargets => [1, 2, 4, 6, 12, 24, 48, 144, 432, 1008];
  double get feeRate => feeEstimate.feeRate == 0 ? 0.0002 : feeEstimate.feeRate;

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    customFeeController.dispose();
    labelController.dispose();
    addressBookProvider.removeListener(notifyListeners);
    super.dispose();
  }

  void onUnitChanged(Unit value) {
    unit = value;
    notifyListeners();
  }

  void onSubtractFeeChanged(bool value) {
    subtractFee = value;
    notifyListeners();
  }

  Future<void> onUseAvailableBalance() async {
    // Get the balance from the node
    try {
      subtractFee = true;
      final balance = balanceProvider.balance - feeRate;
      amountController.text = balance.toStringAsFixed(8);
      notifyListeners();
    } catch (error) {
      log.e('Error converting satoshi to BTC: $error');
      setError(error.toString());
    }
  }

  void clearAddress() {
    addressController.clear();
    notifyListeners();
  }

  void setFeeType(String value) {
    feeType = value;
    if (feeType == 'recommended') {
      useMinimumFee = false;
    }
    notifyListeners();
  }

  void setConfirmationTarget(int? value) {
    if (value == null) {
      return;
    }

    confirmationTarget = value;
    notifyListeners();
    fetchEstimate();
  }

  Future<void> fetchEstimate() async {
    setBusy(true);
    try {
      final estimate = await api.bitcoind.estimateSmartFee(confirmationTarget);
      Logger().d(
        'Estimate: estimate=${estimate.feeRate} errors=${estimate.errors}',
      );
      feeEstimate = estimate;
    } catch (error) {
      setError(error.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> sendTransaction(BuildContext context) async {
    setBusy(true);
    if (addressController.text.isEmpty) {
      showSnackBar(context, 'Please enter an address');
      return;
    }
    if (amountController.text.isEmpty) {
      showSnackBar(context, 'Please enter an amount');
      return;
    }
    if (feeType == 'custom' && customFeeController.text.isEmpty) {
      showSnackBar(context, 'Please enter a custom fee');
      return;
    }

    try {
      final txid = await api.wallet.sendTransaction(
        addressController.text,
        btcToSatoshi(
          double.parse(amountController.text) - (subtractFee ? feeRate : 0),
        ),
        btcPerKvB: feeType == 'recommended' ? feeRate : double.parse(customFeeController.text),
        label: labelController.text,
      );
      Logger().d('Sent transaction: txid=$txid');
      if (context.mounted) {
        showSnackBar(context, 'Sent in txid=$txid');
      }
    } catch (error) {
      Logger().e('Error sending transaction: $error');
      if (context.mounted) {
        showSnackBar(context, 'Could not send transaction $error', duration: 5);
      }
    } finally {
      setBusy(false);
      notifyListeners();
      await transactionsProvider.fetch();
      await addressBookProvider.fetch();
      await balanceProvider.fetch();
    }
  }

  void setUseMinimumFee(bool? value) {
    useMinimumFee = value ?? false;
    if (useMinimumFee) {
      customFeeController.text = '10.00'; // Set to minimum fee
    }
    notifyListeners();
  }

  void onFeeUnitChanged(Unit value) {
    feeUnit = value;
    notifyListeners();
  }

  String getConfirmationTargetLabel(int target) {
    switch (target) {
      case 1:
        return '10 minutes (next block)';
      case 2:
        return '20 minutes (2 blocks)';
      case 4:
        return '40 minutes (4 blocks)';
      case 6:
        return '60 minutes (6 blocks)';
      case 12:
        return '2 hours (12 blocks)';
      case 24:
        return '4 hours (24 blocks)';
      case 48:
        return '8 hours (48 blocks)';
      case 144:
        return '24 hours (144 blocks)';
      case 432:
        return '3 days (504 blocks)';
      case 1008:
        return '7 days (1008 blocks)';
      default:
        return '$target minutes';
    }
  }

  Future<void> clearAll() async {
    addressController.clear();
    amountController.text = '0.00';
    customFeeController.clear();
    unit = Unit.BTC;
    subtractFee = false;
    feeType = 'recommended';
    confirmationTarget = 2;
    useMinimumFee = false;
    notifyListeners();
  }

  void onAddressSelected(AddressBookEntry? entry) {
    if (entry != null) {
      addressController.text = entry.address;
      labelController.text = entry.label;
      selectedEntry = entry;
      notifyListeners();
    }
  }

  void handleBitcoinURI(BitcoinURI uri) {
    addressController.text = uri.address;
    if (uri.amount != null) {
      amountController.text = uri.amount!.toString();
    }
    if (uri.label != null) {
      labelController.text = uri.label!;
    }
    notifyListeners();
  }

  AddressBookEntry get matchingEntry => addressBookProvider.sendEntries.firstWhere(
        (e) => e.address == addressController.text,
        orElse: () => AddressBookEntry(id: Int64(0), label: '', address: '', direction: Direction.DIRECTION_SEND),
      );

  void _onAddressChanged() {
    decodeURI(); // Keep existing URI decoder

    final entry = matchingEntry;
    if (entry.id != Int64(0)) {
      // If we found a matching entry
      labelController.text = entry.label;
      selectedEntry = entry;
    } else {
      // Clear label if address doesn't match any entry
      labelController.text = '';
      selectedEntry = null;
    }
    notifyListeners();
  }

  void _onAddressBookChanged() {
    // When address book changes, update label if this address exists
    _onAddressChanged();
  }
}
