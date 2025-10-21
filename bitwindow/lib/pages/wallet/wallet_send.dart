import 'dart:io';
import 'dart:math';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pbserver.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class SendTab extends ViewModelWidget<SendPageViewModel> {
  const SendTab({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        children: [
          PayFromAndFeeCard(),
          PayToCard(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SailButton(
                label: 'Send',
                onPressed: () => viewModel.sendTransaction(context),
              ),
              const SizedBox(width: SailStyleValues.padding08),
              SailButton(
                variant: ButtonVariant.ghost,
                label: 'Clear All',
                onPressed: viewModel.clearAll,
              ),
            ],
          ),
          SailSpacing(SailStyleValues.padding64),
        ],
      ),
    );
  }
}

String calculateLabel(RecipientModel recipient, int index, BitcoinUnit currentUnit) {
  if (recipient.amountController.text.isEmpty &&
      recipient.addressController.text.isEmpty &&
      recipient.matchingAddressLabel.isEmpty) {
    return 'Recipient ${index + 1}';
  }

  final recipientLabel = recipient.matchingAddressLabel.isNotEmpty
      ? recipient.matchingAddressLabel
      : recipient.addressController.text.isEmpty
      ? '<Unknown>'
      : recipient.addressController.text.substring(0, min(recipient.addressController.text.length, 10));

  if (recipient.amountController.text.isEmpty) {
    return recipientLabel;
  }

  final amountBTC = parseAmountInUnit(recipient.amountController.text, currentUnit);
  final formattedAmount = formatBitcoinWithUnit(amountBTC, currentUnit);

  return '$recipientLabel ($formattedAmount)';
}

class PayToCard extends ViewModelWidget<SendPageViewModel> {
  const PayToCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    // Build a tab for each recipient
    final List<TabItem> tabs = [
      for (int i = 0; i < viewModel.recipients.length; i++)
        SingleTabItem(
          label: calculateLabel(viewModel.recipients[i], i, viewModel.currentUnit),
          child: _RecipientFields(
            key: ValueKey('recipient_fields_${viewModel.recipients[i].id}'),
            index: i,
            recipient: viewModel.recipients[i],
            addressBookEntries: viewModel.addressBookEntries,
            selectedEntry: viewModel.selectedEntry,
            onAddressSelected: viewModel.onAddressSelected,
            onUseAvailableBalance: viewModel.onUseAvailableBalance,
            subtractFee: viewModel.recipients[i].subtractFee,
            onSubtractFeeChanged: (val) {
              viewModel.recipients[i].subtractFee = val;
              viewModel.notifyListeners();
            },
            currentUnit: viewModel.currentUnit,
            onSaveToAddressBook: viewModel.saveToAddressBook,
          ),
          icon: SailSVGAsset.iconClose,
          onIconTap: () => viewModel.removeRecipient(i),
          onTap: () => viewModel.selectRecipient(i),
        ),
      // "+" tab at the end
      TabItem(
        label: '',
        child: const SizedBox.shrink(),
        onTap: viewModel.addRecipient,
        icon: SailSVGAsset.plus, // Use your plus icon asset here
      ),
    ];

    return SailCard(
      title: 'Pay To',
      child: SizedBox(
        height: 200,
        child: InlineTabBar(
          tabs: tabs,
          selectedIndex: viewModel.selectedRecipientIndex,
          onTabChanged: (index) {
            if (index < viewModel.recipients.length) {
              viewModel.selectRecipient(index);
            }
          },
        ),
      ),
    );
  }
}

// Extracted widget for recipient fields
class _RecipientFields extends StatelessWidget {
  final RecipientModel recipient;
  final List<AddressBookEntry> addressBookEntries;
  final AddressBookEntry? selectedEntry;
  final ValueChanged<AddressBookEntry?> onAddressSelected;
  final Future<void> Function(int index) onUseAvailableBalance;
  final bool subtractFee;
  final ValueChanged<bool> onSubtractFeeChanged;
  final int index;
  final BitcoinUnit currentUnit;
  final Future<void> Function(BuildContext context, String address) onSaveToAddressBook;

  const _RecipientFields({
    super.key,
    required this.index,
    required this.recipient,
    required this.addressBookEntries,
    required this.selectedEntry,
    required this.onAddressSelected,
    required this.onUseAvailableBalance,
    required this.subtractFee,
    required this.onSubtractFeeChanged,
    required this.currentUnit,
    required this.onSaveToAddressBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        SailTextField(
          key: Key('recipient_address_$key'),
          label: 'Address',
          controller: recipient.addressController,
          hintText: 'Enter a single L1 bitcoin-address (e.g. 1NS17iag...)',
          size: TextFieldSize.small,
          suffixWidget: SailRow(
            children: [
              PasteButton(
                onPaste: (text) {
                  recipient.addressController.text = text;
                },
              ),
              if (recipient.addressController.text.isNotEmpty &&
                  !addressBookEntries.any((e) => e.address == recipient.addressController.text))
                SailButton(
                  label: 'Save',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => onSaveToAddressBook(context, recipient.addressController.text),
                ),
              Flexible(
                child: SailDropdownButton<AddressBookEntry>(
                  value: null,
                  hint: addressBookEntries.isEmpty ? 'No Addresses Saved' : (selectedEntry?.label ?? 'Address Book'),
                  items: addressBookEntries.isEmpty
                      ? []
                      : addressBookEntries.map((entry) {
                          return SailDropdownItem<AddressBookEntry>(
                            value: entry,
                            label: entry.label,
                          );
                        }).toList(),
                  icon: SailSVG.fromAsset(
                    SailSVGAsset.bookUser,
                    width: 13,
                    color: theme.colors.inactiveNavText,
                  ),
                  onChanged: onAddressSelected,
                ),
              ),
            ],
          ),
        ),
        NumericField(
          key: Key('recipient_amount_$key'),
          label: 'Amount (${currentUnit.symbol})',
          controller: recipient.amountController,
          textFieldType: currentUnit == BitcoinUnit.btc ? TextFieldType.bitcoin : TextFieldType.number,
          suffixWidget: SailButton(
            label: 'MAX',
            variant: ButtonVariant.link,
            onPressed: () async => onUseAvailableBalance(index),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class RecipientModel extends ChangeNotifier {
  final String id = UniqueKey().toString();
  AddressBookProvider get addressBookProvider => GetIt.I<AddressBookProvider>();
  List<AddressBookEntry> get addressBookEntries => addressBookProvider.sendEntries;

  final TextEditingController addressController;
  final TextEditingController amountController;
  bool subtractFee;
  String get matchingAddressLabel =>
      addressBookEntries.firstWhereOrNull((e) => e.address == addressController.text)?.label ?? '';

  RecipientModel({
    String address = '',
    String amount = '',
    String label = '',
    this.subtractFee = false,
  }) : addressController = TextEditingController(text: address),
       amountController = TextEditingController(text: amount) {
    addressController.addListener(notifyListeners);
    amountController.addListener(notifyListeners);
  }
}

class PayFromCard extends ViewModelWidget<SendPageViewModel> {
  const PayFromCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SailCard(
      title: 'Pay From',
      child: UTXOSelector(
        allUtxos: viewModel.allUtxos,
        selectedUtxos: viewModel.selectedUtxos,
        onSelectionChanged: viewModel.onSelectionChanged,
      ),
    );
  }
}

class FeeCard extends ViewModelWidget<SendPageViewModel> {
  const FeeCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SailCard(
      title: 'Fee',
      child: SailTextField(
        controller: viewModel.feeController,
        hintText: 'Fee (in ${viewModel.currentUnit.symbol})',
        textFieldType: viewModel.currentUnit == BitcoinUnit.btc ? TextFieldType.bitcoin : TextFieldType.number,
        suffixWidget: SailRow(
          spacing: 0,
          children: [
            SailText.primary13(viewModel.currentUnit.symbol),
            SailDropdownButton<int>(
              value: null,
              hint: 'Estimate',
              items: [
                SailDropdownItem(value: 1, label: 'Low (1 block)'),
                SailDropdownItem(value: 3, label: 'Medium (3 blocks)'),
                SailDropdownItem(value: 6, label: 'High (6 blocks)'),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await viewModel.estimateFee(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PayFromAndFeeCard extends ViewModelWidget<SendPageViewModel> {
  const PayFromAndFeeCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return SailRow(
            spacing: SailStyleValues.padding16,
            children: [
              Expanded(child: PayFromCard()),
              Expanded(child: FeeCard()),
            ],
          );
        } else {
          return SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              PayFromCard(),
              FeeCard(),
            ],
          );
        }
      },
    );
  }
}

class SendPageViewModel extends BaseViewModel {
  Logger get log => GetIt.I<Logger>();

  BalanceProvider get balanceProvider => GetIt.I<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I<BlockchainProvider>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();
  AddressBookProvider get addressBookProvider => GetIt.I<AddressBookProvider>();
  BitwindowRPC get bitwindowd => GetIt.I<BitwindowRPC>();
  SettingsProvider get settingsProvider => GetIt.I<SettingsProvider>();

  BitcoinUnit get currentUnit => settingsProvider.bitcoinUnit;

  List<AddressBookEntry> get addressBookEntries => addressBookProvider.sendEntries;
  AddressBookEntry? selectedEntry;
  TextEditingController selectedUTXOs = TextEditingController();
  late TextEditingController feeController;
  List<UnspentOutput> get allUtxos => transactionsProvider.utxos.sorted(
    (a, b) {
      final dateCompare = b.receivedAt.toDateTime().compareTo(a.receivedAt.toDateTime());
      if (dateCompare != 0) return dateCompare;
      return a.output.compareTo(b.output);
    },
  );

  List<UnspentOutput> selectedUtxos = [];

  List<RecipientModel> recipients = [];
  int selectedRecipientIndex = 0;
  BitcoinUnit? _previousUnit;

  void _onRecipientChanged() {
    notifyListeners();
  }

  void _onUnitChanged() {
    final newUnit = currentUnit;
    if (_previousUnit != null && _previousUnit != newUnit) {
      _convertAllAmountsToNewUnit(_previousUnit!, newUnit);
    }
    _previousUnit = newUnit;
    notifyListeners();
  }

  void _convertAllAmountsToNewUnit(BitcoinUnit fromUnit, BitcoinUnit toUnit) {
    // Convert fee
    if (feeController.text.isNotEmpty) {
      final feeSats = parseAmountToSatoshis(feeController.text, fromUnit);
      if (toUnit == BitcoinUnit.btc) {
        feeController.text = satoshiToBTC(feeSats).toStringAsFixed(8);
      } else {
        feeController.text = feeSats.toString();
      }
    }

    // Convert all recipient amounts
    for (final recipient in recipients) {
      if (recipient.amountController.text.isNotEmpty) {
        final amountSats = parseAmountToSatoshis(recipient.amountController.text, fromUnit);
        if (toUnit == BitcoinUnit.btc) {
          recipient.amountController.text = satoshiToBTC(amountSats).toStringAsFixed(8);
        } else {
          recipient.amountController.text = amountSats.toString();
        }
      }
    }
  }

  SendPageViewModel() {
    _previousUnit = currentUnit;
    if (currentUnit == BitcoinUnit.btc) {
      feeController = TextEditingController(text: '0.00010000');
    } else {
      feeController = TextEditingController(text: '10000');
    }
    addressBookProvider.addListener(notifyListeners);
    transactionsProvider.addListener(_clearStaleSelectedUTXOs);
    settingsProvider.addListener(_onUnitChanged);
    init();
    final initialRecipient = RecipientModel();
    initialRecipient.addListener(_onRecipientChanged);
    recipients = [initialRecipient];
  }

  Future<void> _clearStaleSelectedUTXOs() async {
    final justFromWallet = allUtxos.where((u) => selectedUtxos.contains(u)).toList();
    if (justFromWallet.length != selectedUtxos.length) {
      selectedUtxos = justFromWallet;
    }

    notifyListeners();
  }

  Future<void> init() async {
    applicationDir = await Environment.datadir();
    logFile = await getLogFile();
  }

  Directory? applicationDir;
  File? logFile;

  @override
  void dispose() {
    for (final recipient in recipients) {
      recipient.removeListener(_onRecipientChanged);
    }
    addressBookProvider.removeListener(notifyListeners);
    settingsProvider.removeListener(_onUnitChanged);
    super.dispose();
  }

  Future<void> onUseAvailableBalance(int index) async {
    try {
      // never send more than their max selected amount
      double availableAmount = satoshiToBTC(selectedUtxos.fold(0, (sum, utxo) => sum + utxo.valueSats.toInt()));
      if (availableAmount == 0) {
        // if sum of all selected utxos, none are selected! defer to their balance
        availableAmount = balanceProvider.balance;
      }

      // 1. Sum up the amounts of all recipients except the one at 'index'
      double sumOtherRecipients = 0.0;
      for (int i = 0; i < recipients.length; i++) {
        if (i == index) continue;
        final amountBTC = parseAmountInUnit(recipients[i].amountController.text, currentUnit);
        sumOtherRecipients += amountBTC;
      }

      // 2. Calculate available balance minus fee
      final feeSats = parseAmountToSatoshis(feeController.text.isEmpty ? '0' : feeController.text, currentUnit);
      final available = availableAmount - satoshiToBTC(feeSats);

      // 3. Set the remaining amount for the recipient at 'index'
      final remaining = available - sumOtherRecipients;
      if (remaining < 0) {
        if (currentUnit == BitcoinUnit.btc) {
          recipients[index].amountController.text = '0.00';
        } else {
          recipients[index].amountController.text = '0';
        }
      } else {
        if (currentUnit == BitcoinUnit.btc) {
          recipients[index].amountController.text = remaining.toStringAsFixed(8);
        } else {
          final sats = btcToSatoshi(remaining);
          recipients[index].amountController.text = sats.toString();
        }
      }

      notifyListeners();
    } catch (error) {
      log.e('Error calculating available balance: $error');
      setError(error.toString());
    }
  }

  void clearAddress() {
    notifyListeners();
  }

  Future<void> sendTransaction(BuildContext context) async {
    setBusy(true);

    // Check if all recipients have an address
    final missingAddress = recipients.indexWhere((r) => r.addressController.text.trim().isEmpty);
    if (missingAddress != -1) {
      showSnackBar(context, 'Please enter an address for all recipients.');
      setBusy(false);
      return;
    }

    // Check if all recipients have an amount
    final missingAmount = recipients.indexWhere((r) => r.amountController.text.trim().isEmpty);
    if (missingAmount != -1) {
      showSnackBar(context, 'Please enter an amount for all recipients.');
      setBusy(false);
      return;
    }

    final feeSats = parseAmountToSatoshis(feeController.text, currentUnit);
    if (feeSats <= 0) {
      showSnackBar(context, 'Please enter a valid fee.');
      setBusy(false);
      return;
    }

    try {
      // Build destinations map for all recipients, summing amounts for duplicate addresses
      final destinations = <String, int>{};
      for (int i = 0; i < recipients.length; i++) {
        final r = recipients[i];
        final address = r.addressController.text;
        final satoshis = parseAmountToSatoshis(r.amountController.text, currentUnit);

        // Sum amounts for duplicate addresses
        destinations[address] = (destinations[address] ?? 0) + satoshis;
      }

      final txid = await bitwindowd.wallet.sendTransaction(
        destinations,
        fixedFeeSats: feeSats,
        requiredInputs: selectedUtxos,
      );
      await clearAll();
      log.d('Sent transaction: txid=$txid');
      if (context.mounted) {
        showSnackBar(context, 'Sent in txid=$txid');
      }
    } catch (error) {
      log.e('Error sending transaction: $error');
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

  Future<void> clearAll() async {
    // Remove listeners from all recipients
    for (final recipient in recipients) {
      recipient.removeListener(_onRecipientChanged);
    }
    recipients.clear();

    // Optionally, add a new empty recipient and attach listener
    final initialRecipient = RecipientModel();
    initialRecipient.addListener(_onRecipientChanged);
    recipients.add(initialRecipient);
    selectedRecipientIndex = 0;
    if (currentUnit == BitcoinUnit.btc) {
      feeController.text = '0.00010000';
    } else {
      feeController.text = '10000';
    }
    selectedUtxos = [];

    notifyListeners();
  }

  void onAddressSelected(AddressBookEntry? entry) {
    if (entry != null) {
      selectedEntry = entry;
      recipients[selectedRecipientIndex].addressController.text = entry.address;
      notifyListeners();
    }
  }

  Future<void> saveToAddressBook(BuildContext context, String address) async {
    if (address.isEmpty) return;
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => _SaveToAddressBookDialog(
        address: address,
        addressBookProvider: addressBookProvider,
        log: log,
      ),
    );
  }

  void handleBitcoinURI(BitcoinURI uri) async {
    await clearAll();
    if (recipients.isNotEmpty) {
      final recipient = recipients.first;
      recipient.addressController.text = uri.address;
      if (uri.amount != null) {
        recipient.amountController.text = uri.amount!.toString();
      }
    }
    notifyListeners();
  }

  void onSelectionChanged(List<UnspentOutput> selected) {
    final justFromWallet = allUtxos.where((u) => selected.contains(u)).toList();
    selectedUtxos = List.from(justFromWallet);
    notifyListeners();
  }

  void addRecipient() {
    final recipient = RecipientModel();
    recipient.addListener(_onRecipientChanged);
    recipients.add(recipient);
    selectedRecipientIndex = recipients.length - 1;
    notifyListeners();
  }

  void selectRecipient(int index) {
    selectedRecipientIndex = index;
    notifyListeners();
  }

  void removeRecipient(int index) {
    recipients[index].removeListener(_onRecipientChanged);
    recipients.removeAt(index);
    if (index != 0) {
      selectedRecipientIndex = index - 1;
    }
    notifyListeners();
  }

  Future<void> estimateFee(int confTarget) async {
    try {
      final response = await bitwindowd.bitcoind.estimateSmartFee(confTarget);
      if (response.hasFeeRate()) {
        // Convert BTC/kvB to sats/byte, then estimate for a typical transaction
        final btcPerKvb = response.feeRate;
        final satsPerByte = (btcPerKvb * 100000000) / 1000;

        // Estimate transaction size: base (10) + inputs (~148 each) + outputs (~34 each)
        final numInputs = selectedUtxos.isEmpty ? 2 : selectedUtxos.length;
        final numOutputs = recipients.length + 1; // recipients + change
        final estimatedSize = 10 + (numInputs * 148) + (numOutputs * 34);

        final estimatedFeeSats = (satsPerByte * estimatedSize).ceil();
        if (currentUnit == BitcoinUnit.btc) {
          feeController.text = satoshiToBTC(estimatedFeeSats).toStringAsFixed(8);
        } else {
          feeController.text = estimatedFeeSats.toString();
        }
        notifyListeners();
      }
    } catch (error) {
      log.e('Error estimating fee: $error');
    }
  }
}

class UTXOSelector extends StatefulWidget {
  final List<UnspentOutput> allUtxos;
  final List<UnspentOutput> selectedUtxos;
  final ValueChanged<List<UnspentOutput>> onSelectionChanged;

  const UTXOSelector({
    super.key,
    required this.allUtxos,
    required this.selectedUtxos,
    required this.onSelectionChanged,
  });

  @override
  State<UTXOSelector> createState() => _UTXOSelectorState();
}

class _UTXOSelectorState extends State<UTXOSelector> {
  @override
  void initState() {
    super.initState();
  }

  String formatUnspentOutput(UnspentOutput u, {bool long = true}) {
    final amount = formatBitcoin(satoshiToBTC(u.valueSats.toInt()));
    return '${u.output.substring(0, 6)}..:${u.output.split(':').last} ($amount)${long ? ' received ${formatDate(u.receivedAt.toDateTime(), long: false)}' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final utxoItems = widget.allUtxos
        .map(
          (u) => SailDropdownItem(
            value: u.output,
            label: formatUnspentOutput(u, long: true),
            monospace: true,
          ),
        )
        .toList();

    final selectedValues = widget.selectedUtxos.map((u) => u.output).toList();

    return SailColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SailTextField(
                controller: TextEditingController(
                  text: widget.selectedUtxos.map((u) => formatUnspentOutput(u, long: false)).join('\n'),
                ),
                readOnly: true,
                maxLines: null,
                hintText: 'Any UTXO',
                suffixWidget: SailMultiSelectDropdown(
                  items: utxoItems,
                  selectedValues: selectedValues,
                  onSelected: (String output) {
                    setState(() {
                      if (selectedValues.contains(output)) {
                        widget.selectedUtxos.removeWhere((u) => u.output == output);
                      } else {
                        final utxo = widget.allUtxos.firstWhere((u) => u.output == output);
                        widget.selectedUtxos.add(utxo);
                      }
                    });
                    widget.onSelectionChanged(widget.selectedUtxos);
                  },
                  buttonVariant: ButtonVariant.ghost,
                  searchPlaceholder: 'Search UTXOs',
                  selectedCountText: 'Select UTXO(s)',
                  showDropdownArrow: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SaveToAddressBookDialog extends StatefulWidget {
  final String address;
  final AddressBookProvider addressBookProvider;
  final Logger log;

  const _SaveToAddressBookDialog({
    required this.address,
    required this.addressBookProvider,
    required this.log,
  });

  @override
  State<_SaveToAddressBookDialog> createState() => _SaveToAddressBookDialogState();
}

class _SaveToAddressBookDialogState extends State<_SaveToAddressBookDialog> {
  final TextEditingController labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    labelController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    labelController.removeListener(_onTextChanged);
    labelController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SailCard(
          title: 'Save to Address Book',
          subtitle: '',
          withCloseButton: true,
          child: SailColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.min,
            children: [
              SailTextField(
                label: 'Address',
                controller: TextEditingController(text: widget.address),
                hintText: widget.address,
                readOnly: true,
                size: TextFieldSize.small,
                suffixWidget: CopyButton(
                  text: widget.address,
                ),
              ),
              SailTextField(
                label: 'Label',
                controller: labelController,
                hintText: 'Enter a label for this address',
                size: TextFieldSize.small,
              ),
              SailButton(
                label: 'Save',
                onPressed: () async {
                  if (labelController.text.isEmpty) return;
                  try {
                    await widget.addressBookProvider.createEntry(
                      labelController.text,
                      widget.address,
                      Direction.DIRECTION_SEND,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      showSnackBar(context, 'Address saved to address book');
                    }
                  } catch (e) {
                    widget.log.e('Error saving to address book: $e');
                    if (context.mounted) {
                      showSnackBar(context, 'Failed to save address: $e');
                    }
                  }
                },
                disabled: labelController.text.isEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
