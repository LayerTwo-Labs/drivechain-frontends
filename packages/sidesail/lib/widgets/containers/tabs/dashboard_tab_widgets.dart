import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

class DashboardGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  final Widget? widgetTrailing;
  final Widget? endWidget;

  const DashboardGroup({
    super.key,
    required this.title,
    required this.children,
    this.widgetTrailing,
    this.endWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: 0,
      withDivider: true,
      children: [
        Container(
          height: 36,
          color: theme.colors.actionHeader,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: Row(
              children: [
                SailRow(
                  spacing: SailStyleValues.padding10,
                  children: [
                    SailText.primary13(
                      title,
                      bold: true,
                    ),
                    if (widgetTrailing != null) widgetTrailing!,
                  ],
                ),
                Expanded(child: Container()),
                if (endWidget != null) endWidget!,
              ],
            ),
          ),
        ),
        for (final child in children) child,
      ],
    );
  }
}

class SendOnSidechainAction extends StatelessWidget {
  final Future<String> Function(String address, double amount)? customSendAction;

  const SendOnSidechainAction({
    super.key,
    this.customSendAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SendOnSidechainViewModel(customSendAction: customSendAction),
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
              value: '${(viewModel.sidechainExpectedFee ?? 0).toStringAsFixed(8)} ${viewModel.ticker}',
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
      ((double.tryParse(bitcoinAmountController.text) ?? 0) + (sidechainExpectedFee ?? 0)).toStringAsFixed(8);
  String get ticker => _sidechainContainer.rpc.chain.ticker;

  double? sidechainExpectedFee;
  double? get sendAmount => double.tryParse(bitcoinAmountController.text);

  final Future<String> Function(String address, double amount)? customSendAction;

  SendOnSidechainViewModel({this.customSendAction}) {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);
    init();
  }

  void init() async {
    await estimateFee();
  }

  void executeSendOnSidechain(BuildContext context) async {
    setBusy(true);
    onSidechainSend(context);
    setBusy(false);

    await _router.pop();
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

    // also pop the info modal
    await _router.pop();
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

class ReceiveOnSidechainAction extends StatelessWidget {
  final Future<String> Function()? customReceiveAction;

  const ReceiveOnSidechainAction({
    super.key,
    this.customReceiveAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ReceiveOnSidechainViewModel(customReceiveAction: customReceiveAction),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Receive on sidechain',
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

class ReceiveOnSidechainViewModel extends BaseViewModel {
  SidechainContainer get _rpc => GetIt.I.get<SidechainContainer>();
  final log = Logger(level: Level.debug);

  String? sidechainAddress;
  final Future<String> Function()? customReceiveAction;

  ReceiveOnSidechainViewModel({this.customReceiveAction}) {
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

    return await _rpc.rpc.sideGenerateAddress();
  }
}
