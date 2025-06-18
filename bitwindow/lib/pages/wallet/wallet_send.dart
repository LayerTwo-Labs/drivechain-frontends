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

String calculateLabel(RecipientModel recipient, int index) {
  if (recipient.amountController.text.isEmpty &&
      recipient.addressController.text.isEmpty &&
      recipient.matchingAddressLabel.isEmpty) {
    return 'Recipient ${index + 1}';
  }

  final amount = double.tryParse(recipient.amountController.text);

  final recipientLabel = recipient.matchingAddressLabel.isNotEmpty
      ? recipient.matchingAddressLabel
      : recipient.addressController.text.isEmpty
          ? '<Unknown>'
          : recipient.addressController.text.substring(0, min(recipient.addressController.text.length, 10));

  return '$recipientLabel ${amount != null ? '(${formatBitcoin(amount)})' : ''}';
}

class PayToCard extends ViewModelWidget<SendPageViewModel> {
  const PayToCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    // Build a tab for each recipient
    final List<TabItem> tabs = [
      for (int i = 0; i < viewModel.recipients.length; i++)
        SingleTabItem(
          label: calculateLabel(viewModel.recipients[i], i),
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
  });

  @override
  Widget build(BuildContext context) {
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
              // TODO: Add this dropdown
              /*
              Flexible(
                child: SailDropdownButton<AddressBookEntry>(
                  value: null,
                  hint: selectedEntry?.label ?? 'Address Book',
                  items: addressBookEntries.map((entry) {
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
              */
            ],
          ),
        ),
        NumericField(
          key: Key('recipient_amount_$key'),
          label: 'Amount',
          controller: recipient.amountController,
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
  })  : addressController = TextEditingController(text: address),
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
        hintText: 'Hard-coded fee (in sats)',
        suffixWidget: SailText.primary13('sats'),
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

  List<AddressBookEntry> get addressBookEntries => addressBookProvider.sendEntries;
  AddressBookEntry? selectedEntry;
  TextEditingController selectedUTXOs = TextEditingController();
  TextEditingController feeController = TextEditingController(text: '1000');
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

  void _onRecipientChanged() {
    notifyListeners();
  }

  SendPageViewModel() {
    addressBookProvider.addListener(notifyListeners);
    transactionsProvider.addListener(notifyListeners);
    init();
    final initialRecipient = RecipientModel();
    initialRecipient.addListener(_onRecipientChanged);
    recipients = [initialRecipient];
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
    super.dispose();
  }

  Future<void> onUseAvailableBalance(int index) async {
    try {
      // 1. Sum up the amounts of all recipients except the one at 'index'
      double sumOtherRecipients = 0.0;
      for (int i = 0; i < recipients.length; i++) {
        if (i == index) continue;
        final amt = double.tryParse(recipients[i].amountController.text) ?? 0.0;
        sumOtherRecipients += amt;
      }

      // 2. Calculate available balance minus fee
      final available = balanceProvider.balance - satoshiToBTC((int.tryParse(feeController.text) ?? 1000));

      // 3. Set the remaining amount for the recipient at 'index'
      final remaining = available - sumOtherRecipients;
      if (remaining < 0) {
        recipients[index].amountController.text = '0.00';
      } else {
        recipients[index].amountController.text = remaining.toStringAsFixed(8);
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

    try {
      // Build destinations map for all recipients, summing amounts for duplicate addresses
      final destinations = <String, int>{};
      for (int i = 0; i < recipients.length; i++) {
        final r = recipients[i];
        var amount = double.tryParse(r.amountController.text) ?? 0.0;
        final address = r.addressController.text;
        final satoshis = btcToSatoshi(amount);

        // Sum amounts for duplicate addresses
        destinations[address] = (destinations[address] ?? 0) + satoshis;
      }

      final txid = await bitwindowd.wallet.sendTransaction(
        destinations,
        fixedFeeSats: int.tryParse(feeController.text) ?? 1000,
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
    feeController.text = '1000';
    selectedUtxos = [];

    notifyListeners();
  }

  void onAddressSelected(AddressBookEntry? entry) {
    if (entry != null) {
      selectedEntry = entry;
      notifyListeners();
    }
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
    selectedUtxos = List.from(selected);
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
