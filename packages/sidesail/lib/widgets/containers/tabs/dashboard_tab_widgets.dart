import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

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
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Send on sidechain',
          endActionButton: SailButton.primary(
            'Execute send',
            disabled: viewModel.bitcoinAddressController.text.isEmpty || viewModel.bitcoinAmountController.text.isEmpty,
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.executeSendOnSidechain(context);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAddressController,
              hintText: 'Enter a sidechain-address',
              autofocus: true,
            ),
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'Enter a ${viewModel.ticker}-amount',
              suffixText: viewModel.ticker,
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Fee',
              value: '${(formatBitcoin(viewModel.sidechainExpectedFee ?? 0))} ${viewModel.ticker}',
            ),
            StaticActionField(
              label: 'Total amount',
              value: '${viewModel.totalBitcoinAmount} ${viewModel.ticker}',
            ),
          ],
        );
      }),
    );
  }
}

class SendOnSidechainViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();

  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  SidechainContainer get _rpc => GetIt.I.get<SidechainContainer>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      formatBitcoin(((double.tryParse(bitcoinAmountController.text) ?? 0) + (sidechainExpectedFee ?? 0)));
  String get ticker => _sidechainContainer.rpc.chain.ticker;

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
    final estimate = await _rpc.rpc.sideEstimateFee();
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

    return await _rpc.rpc.sideSend(
      address,
      amount,
      false,
    );
  }
}

class ReceiveAction extends StatelessWidget {
  final Future<String> Function()? customReceiveAction;
  final String? customTitle;

  const ReceiveAction({
    super.key,
    this.customReceiveAction,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ReceiveViewModel(customReceiveAction: customReceiveAction),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          customTitle ?? 'Receive on sidechain',
          endActionButton: SailButton.primary(
            'Generate new address',
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              await viewModel.generateSidechainAddress();
            },
          ),
          children: [
            StaticActionField(
              label: 'Address',
              value: viewModel.sidechainAddress ?? '',
              copyable: true,
            ),
          ],
        );
      }),
    );
  }
}

class ReceiveViewModel extends BaseViewModel {
  SidechainContainer get _rpc => GetIt.I.get<SidechainContainer>();
  final log = Logger(level: Level.debug);

  String? sidechainAddress;
  final Future<String> Function()? customReceiveAction;

  ReceiveViewModel({this.customReceiveAction}) {
    generateSidechainAddress();
  }

  Future<void> generateSidechainAddress() async {
    sidechainAddress = await _receive();
    notifyListeners();
  }

  Future<String> _receive() async {
    if (customReceiveAction != null) {
      return await customReceiveAction!();
    }

    return await _rpc.rpc.generateZAddress();
  }
}
