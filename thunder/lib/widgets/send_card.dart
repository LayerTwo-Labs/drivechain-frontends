import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ThunderSendCard extends StatelessWidget {
  const ThunderSendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ThunderSendViewModel>.reactive(
      viewModelBuilder: () => ThunderSendViewModel(),
      builder: (context, model, child) {
        final tabs = <TabItem>[
          for (int i = 0; i < model.recipients.length; i++)
            SingleTabItem(
              label: model.tabLabel(i),
              child: _RecipientFields(
                key: ValueKey('recipient_fields_${model.recipients[i].id}'),
                recipient: model.recipients[i],
                onMax: () async => model.useAvailableBalance(i),
              ),
              icon: SailSVGAsset.iconClose,
              onIconTap: () => model.removeRecipient(i),
              onTap: () => model.selectRecipient(i),
            ),
          TabItem(
            label: '',
            child: const SizedBox.shrink(),
            onTap: model.addRecipient,
            icon: SailSVGAsset.plus,
          ),
        ];

        return SailCard(
          title: 'Send on Sidechain',
          error: model.sendError,
          child: SailColumn(
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: InlineTabBar(
                  tabs: tabs,
                  selectedIndex: model.selectedRecipientIndex,
                  onTabChanged: (index) {
                    if (index < model.recipients.length) {
                      model.selectRecipient(index);
                    }
                  },
                ),
              ),
              SailButton(
                label: 'Send',
                disabled: !model.canSend,
                onPressed: () async => model.executeSend(context),
                loading: model.isSending,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecipientFields extends StatelessWidget {
  final SendRecipient recipient;
  final Future<void> Function() onMax;

  const _RecipientFields({super.key, required this.recipient, required this.onMax});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        SailTextField(
          label: 'Address',
          controller: recipient.addressController,
          hintText: 'Enter a bitcoin address',
          size: TextFieldSize.small,
          suffixWidget: PasteButton(
            onPaste: (text) => recipient.addressController.text = text,
          ),
        ),
        NumericField(
          label: 'Amount',
          controller: recipient.amountController,
          hintText: '0.00',
          suffixWidget: SailButton(
            label: 'MAX',
            variant: ButtonVariant.link,
            onPressed: onMax,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class SendRecipient {
  final String id = UniqueKey().toString();
  final addressController = TextEditingController();
  final amountController = TextEditingController();

  void dispose() {
    addressController.dispose();
    amountController.dispose();
  }
}

class ThunderSendViewModel extends BaseViewModel {
  ThunderRPC get _rpc => GetIt.I.get<ThunderRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainTransactionsProvider get _transactionsProvider => GetIt.I.get<SidechainTransactionsProvider>();

  final recipients = <SendRecipient>[];
  int selectedRecipientIndex = 0;
  double? sidechainFee;
  String? sendError;
  bool isSending = false;

  ThunderSendViewModel() {
    addRecipient();
    _balanceProvider.addListener(notifyListeners);
    unawaited(_initFee());
  }

  Future<void> _initFee() async {
    sidechainFee = await _rpc.sideEstimateFee();
    notifyListeners();
  }

  double get balance => _balanceProvider.balance;
  bool get balanceInitialized => _balanceProvider.initialized;
  String get ticker => _rpc.chain.ticker;

  double _amountOf(SendRecipient recipient) => double.tryParse(recipient.amountController.text) ?? 0;
  double get totalAmount => recipients.fold(0.0, (sum, recipient) => sum + _amountOf(recipient));

  bool get canSend {
    if (!balanceInitialized || sidechainFee == null || isSending) {
      return false;
    }
    for (final recipient in recipients) {
      if (recipient.addressController.text.trim().isEmpty) {
        return false;
      }
      final amount = double.tryParse(recipient.amountController.text);
      if (amount == null || amount <= 0) {
        return false;
      }
    }
    return totalAmount + sidechainFee! <= balance;
  }

  String tabLabel(int index) {
    final recipient = recipients[index];
    final address = recipient.addressController.text;
    final amountText = recipient.amountController.text;
    if (address.isEmpty && amountText.isEmpty) {
      return 'Recipient ${index + 1}';
    }
    final name = address.isEmpty ? 'Recipient ${index + 1}' : address.substring(0, min(address.length, 10));
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      return name;
    }
    return '$name (${amount.toStringAsFixed(8)})';
  }

  void addRecipient() {
    final recipient = SendRecipient();
    recipient.addressController.addListener(notifyListeners);
    recipient.amountController.addListener(notifyListeners);
    recipients.add(recipient);
    selectedRecipientIndex = recipients.length - 1;
    notifyListeners();
  }

  void removeRecipient(int index) {
    if (recipients.length == 1) {
      recipients[index].addressController.clear();
      recipients[index].amountController.clear();
      return;
    }
    recipients.removeAt(index).dispose();
    selectedRecipientIndex = min(selectedRecipientIndex, recipients.length - 1);
    notifyListeners();
  }

  void selectRecipient(int index) {
    selectedRecipientIndex = index;
    notifyListeners();
  }

  Future<void> useAvailableBalance(int index) async {
    final others = totalAmount - _amountOf(recipients[index]);
    final available = max(balance - (sidechainFee ?? 0) - others, 0.0);
    recipients[index].amountController.text = available.toStringAsFixed(8);
    notifyListeners();
  }

  Future<void> executeSend(BuildContext context) async {
    sendError = null;

    // The map sums in sats, so two rows with one address make one output.
    final destinationSats = <String, int>{};
    for (final recipient in recipients) {
      final address = recipient.addressController.text.trim();
      if (address.isEmpty) {
        sendError = 'Please enter a destination address';
        notifyListeners();
        return;
      }
      final amount = double.tryParse(recipient.amountController.text);
      if (amount == null || amount <= 0) {
        sendError = 'Please enter a valid amount';
        notifyListeners();
        return;
      }
      // Round, because a double like 0.00000059 * 1e8 lands just under 59.
      destinationSats[address] = (destinationSats[address] ?? 0) + (amount * 100000000).round();
    }

    if (!context.mounted) {
      return;
    }

    isSending = true;
    notifyListeners();

    try {
      final txid = await _rpc.sideSendMany(destinationSats);

      unawaited(_balanceProvider.fetch());
      unawaited(_transactionsProvider.fetch());

      if (!context.mounted) {
        return;
      }

      final totalSats = destinationSats.values.fold(0, (sum, sats) => sum + sats);
      final total = formatBitcoin(satoshiToBTC(totalSats), symbol: ticker);
      final target = destinationSats.length == 1 ? destinationSats.keys.first : '${destinationSats.length} recipients';
      await successDialog(
        context: context,
        action: 'Send on sidechain',
        title: 'You sent $total to $target',
        subtitle: 'TXID: $txid',
      );

      while (recipients.length > 1) {
        recipients.removeLast().dispose();
      }
      recipients.first.addressController.clear();
      recipients.first.amountController.clear();
      selectedRecipientIndex = 0;
    } catch (error) {
      sendError = error.toString();
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _balanceProvider.removeListener(notifyListeners);
    for (final recipient in recipients) {
      recipient.dispose();
    }
    super.dispose();
  }
}
