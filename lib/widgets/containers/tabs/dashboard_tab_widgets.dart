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
import 'package:sidesail/rpc/rpc_testchain.dart';
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
  const SendOnSidechainAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SendOnSidechainViewModel(),
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
            ),
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'Enter a BTC-amount',
              suffixText: 'BTC',
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Fee',
              value: '${viewModel.sidechainExpectedFee ?? 0} BTC',
            ),
            StaticActionField(
              label: 'Total amount',
              value: '${viewModel.totalBitcoinAmount} SBTC',
            ),
          ],
        );
      }),
    );
  }
}

class SendOnSidechainViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  TestchainRPC get _rpc => GetIt.I.get<TestchainRPC>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount => (double.tryParse(bitcoinAmountController.text) ?? 0).toStringAsFixed(8);

  double? sidechainExpectedFee;
  double? get sendAmount => double.tryParse(bitcoinAmountController.text);

  SendOnSidechainViewModel() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);
    init();
  }

  void init() async {
    await estimateFee();
  }

  void executeSendOnSidechain(BuildContext context) async {
    setBusy(true);
    notifyListeners();
    onSidechainSend(context);
    setBusy(false);
    notifyListeners();

    await _router.pop();
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

    await showThemedDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: SailText.primary13(
          'Confirm send',
        ),
        content: SailText.primary13(
          'Do you really want to send ${bitcoinAmountController.text} BTC to $address with $sidechainExpectedFee SC expected fee?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: SailText.primary13('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Pop the currently visible dialog
              Navigator.of(context).pop();

              // This creates a new dialog on success
              _doSidechainSend(
                context,
                address,
                sendAmount!,
              );
            },
            child: SailText.primary13(
              'OK',
            ),
          ),
        ],
      ),
    );
  }

  void _doSidechainSend(
    BuildContext context,
    String address,
    double amount,
  ) async {
    log.i(
      'doing sidechain withdrawal: $amount BTC to $address with $sidechainExpectedFee SC fee',
    );

    try {
      final sendTXID = await _rpc.sideSend(
        address,
        amount,
        false,
      );
      log.i('sent sidechain withdrawal txid: $sendTXID');

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_transactionsProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await showThemedDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: SailText.primary13(
            'Success',
          ),
          content: SailText.primary13(
            'Sent successfully! TXID: $sendTXID',
          ),
          actions: [
            TextButton(
              onPressed: () => _router.popUntilRoot(),
              child: SailText.primary13('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await showThemedDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: SailText.primary13(
            'Failed',
          ),
          content: SailText.primary13(
            'Could not execute sidechain withdrawal ${error.toString()}',
          ),
          actions: [
            TextButton(
              onPressed: () => _router.popUntilRoot(),
              child: SailText.primary13('OK'),
            ),
          ],
        ),
      );
      return;
    }
  }
}

class ReceiveOnSidechainAction extends StatelessWidget {
  const ReceiveOnSidechainAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ReceiveOnSidechainViewModel(),
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
  TestchainRPC get _rpc => GetIt.I.get<TestchainRPC>();
  final log = Logger(level: Level.debug);

  String? sidechainAddress;

  ReceiveOnSidechainViewModel() {
    generateSidechainAddress();
  }

  Future<void> generateSidechainAddress() async {
    sidechainAddress = await _rpc.sideGenerateAddress();
    notifyListeners();
  }
}
