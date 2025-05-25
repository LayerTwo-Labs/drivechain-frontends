import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thunder/providers/transactions_provider.dart';
import 'package:thunder/routing/router.dart';
import 'package:thunder/widgets/containers/dashboard_action_modal.dart';

class SendOnSidechainAction extends StatelessWidget {
  final double? maxAmount;
  final Future<String> Function(String address, double amount)? customSendAction;

  const SendOnSidechainAction({
    super.key,
    this.maxAmount,
    this.customSendAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SendOnSidechainViewModel(
        customSendAction: customSendAction,
        maxAmount: maxAmount,
      ),
      builder: ((context, model, child) {
        return DashboardActionModal(
          'Send on sidechain',
          endActionButton: SailButton(
            variant: ButtonVariant.primary,
            label: 'Execute send',
            disabled: model.bitcoinAddressController.text.isEmpty || model.bitcoinAmountController.text.isEmpty,
            loading: model.isBusy,
            onPressed: () async {
              model.executeSendOnSidechain(context);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: model.bitcoinAddressController,
              hintText: 'Enter a sidechain-address',
              autofocus: true,
            ),
            LargeEmbeddedInput(
              controller: model.bitcoinAmountController,
              hintText: 'Enter a ${model.ticker}-amount',
              suffixText: model.ticker,
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Fee',
              value: (formatBitcoin(model.sidechainExpectedFee ?? 0, symbol: model.ticker)),
            ),
            StaticActionField(
              label: 'Total amount',
              value: model.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class SendOnSidechainViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ThunderRPC get _rpc => GetIt.I.get<ThunderRPC>();

  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionProvider get _transactionsProvider => GetIt.I.get<TransactionProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount => formatBitcoin(
        ((double.tryParse(bitcoinAmountController.text) ?? 0) + (sidechainExpectedFee ?? 0)),
        symbol: ticker,
      );
  String get ticker => _rpc.chain.ticker;

  double? sidechainExpectedFee;
  double? get sendAmount => double.tryParse(bitcoinAmountController.text);

  final Future<String> Function(String address, double amount)? customSendAction;
  final double? maxAmount;

  SendOnSidechainViewModel({
    this.customSendAction,
    this.maxAmount,
  }) {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(_capAmount);
    init();
  }

  void _capAmount() {
    String currentInput = bitcoinAmountController.text;

    if (maxAmount != null && (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount!)) {
      bitcoinAmountController.text = maxAmount.toString();
      bitcoinAmountController.selection =
          TextSelection.fromPosition(TextPosition(offset: bitcoinAmountController.text.length));
    } else {
      notifyListeners();
    }
  }

  void init() async {
    await estimateFee();
  }

  void executeSendOnSidechain(BuildContext context) async {
    setBusy(true);
    onSidechainSend(context);
    setBusy(false);
  }

  Future<void> estimateFee() async {
    final estimate = await _rpc.sideEstimateFee();
    sidechainExpectedFee = estimate;
    notifyListeners();
  }

  void onSidechainSend(BuildContext context) async {
    if (sendAmount == null) {
      log.e('withdrawal amount was empty');
      return;
    }
    if (sidechainExpectedFee == null) {
      log.e('sidechain fee was empty');
      return;
    }

    final address = bitcoinAddressController.text;

    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    _doSidechainSend(
      context,
      address,
      sendAmount!,
    );
  }

  void _doSidechainSend(
    BuildContext context,
    String address,
    double amount,
  ) async {
    log.i(
      'doing sidechain withdrawal: $amount $ticker to $address with $sidechainExpectedFee SC fee',
    );

    try {
      final sendTXID = await _send(address, amount);
      log.i('sent sidechain withdrawal txid: $sendTXID sendTXID');

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_transactionsProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Send on sidechain',
        title: 'You sent $amount $ticker to $address',
        subtitle: 'TXID: $sendTXID',
      );
      // also pop the info modal
      await _router.maybePop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Send on sidechain',
        title: 'Could not execute withdrawal',
        subtitle: error.toString(),
      );
    }
  }

  Future<String> _send(
    String address,
    double amount,
  ) async {
    if (customSendAction != null) {
      return await customSendAction!(address, amount);
    }

    return await _rpc.sideSend(
      address,
      amount,
      false,
    );
  }
}

class ReceiveAction extends StatelessWidget {
  final Future<String> Function()? customReceiveAction;
  final String? customTitle;
  final String? initialAddress;

  const ReceiveAction({
    super.key,
    this.customReceiveAction,
    this.customTitle,
    this.initialAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ReceiveViewModel(
        initialAddress: initialAddress,
        customReceiveAction: customReceiveAction,
      ),
      builder: ((context, model, child) {
        return Padding(
          padding: const EdgeInsets.only(left: SailStyleValues.padding04),
          child: DashboardActionModal(
            customTitle ?? 'Receive on sidechain',
            endActionButton: SailButton(
              variant: ButtonVariant.primary,
              label: 'Generate new address',
              loading: model.isBusy,
              onPressed: () async {
                await model.generateSidechainAddress();
              },
            ),
            children: [
              StaticActionField(
                label: 'Address',
                value: model.address,
                copyable: true,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ReceiveViewModel extends BaseViewModel {
  ThunderRPC get _rpc => GetIt.I.get<ThunderRPC>();
  final log = Logger(level: Level.debug);

  String? sidechainAddress;
  final Future<String> Function()? customReceiveAction;
  final String? initialAddress;
  String get address => sidechainAddress ?? initialAddress ?? '';

  ReceiveViewModel({
    this.customReceiveAction,
    this.initialAddress,
  }) {
    if (initialAddress == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await generateSidechainAddress();
      });
    }
  }

  Future<void> generateSidechainAddress() async {
    sidechainAddress = await _receive();
    notifyListeners();
  }

  Future<String> _receive() async {
    if (customReceiveAction != null) {
      return await customReceiveAction!();
    }

    return await _rpc.getSideAddress();
  }
}
