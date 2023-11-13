import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

class PegOutAction extends StatelessWidget {
  const PegOutAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PegOutViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Peg-out to parent chain',
          endActionButton: SailButton.primary(
            'Execute peg-out',
            disabled: viewModel.bitcoinAddressController.text.isEmpty || viewModel.bitcoinAmountController.text.isEmpty,
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.executePegOut(context);
            },
          ),
          children: [
            Focus(
              autofocus: true,
              child: LargeEmbeddedInput(
                controller: viewModel.bitcoinAddressController,
                hintText: 'Enter a parent chain bitcoin-address',
              ),
            ),
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'Enter a BTC-amount',
              suffixText: 'BTC',
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Parent chain fee',
              value: '${(viewModel.mainchainFee ?? 0).toStringAsFixed(8)} BTC',
            ),
            StaticActionField(
              label: 'Sidechain fee',
              value: '${(viewModel.sidechainFee ?? 0).toStringAsFixed(8)} BTC',
            ),
            StaticActionField(
              label: 'Total amount',
              value: '${viewModel.totalBitcoinAmount} BTC',
            ),
          ],
        );
      }),
    );
  }
}

class PegOutViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  TestchainRPC get _testchain => GetIt.I.get<TestchainRPC>();
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      ((double.tryParse(bitcoinAmountController.text) ?? 0) + (mainchainFee ?? 0) + (sidechainFee ?? 0))
          .toStringAsFixed(8);

  double? sidechainFee;
  double? mainchainFee;
  double? get pegOutAmount => double.tryParse(bitcoinAmountController.text);

  PegOutViewModel() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);
    init();
  }

  void init() async {
    await Future.wait([estimateSidechainFee(), estimateMainchainFee()]);
  }

  void executePegOut(BuildContext context) async {
    setBusy(true);
    notifyListeners();
    onPegOut(context);
    setBusy(false);
    notifyListeners();
  }

  Future<void> estimateSidechainFee() async {
    sidechainFee = await _testchain.sideEstimateFee();
    notifyListeners();
  }

  Future<void> estimateMainchainFee() async {
    mainchainFee = await _mainchain.estimateFee();
    notifyListeners();
  }

  void onPegOut(BuildContext context) async {
    if (pegOutAmount == null) {
      log.e('withdrawal amount was empty');
      return;
    }
    if (sidechainFee == null) {
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

    await infoDialog(
      context: context,
      action: 'Peg-out to parent chain',
      title: 'Confirm withdrawal',
      subtitle:
          'Do you really want to peg-out?\n${bitcoinAmountController.text} BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
      onConfirm: () {
        _doPegOut(
          context,
          address,
          pegOutAmount!,
          sidechainFee!,
          mainchainFee!,
        );
      },
    );
  }

  void _doPegOut(
    BuildContext context,
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  ) async {
    log.i(
      'doing peg-out: $amount BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
    );

    try {
      final withdrawalTxid = await _testchain.mainSend(
        address,
        amount,
        sidechainFee,
        mainchainFee,
      );

      log.i(
        'pegged out successfully',
      );

      if (!context.mounted) {
        return;
      }

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_transactionsProvider.fetch());

      await successDialog(
        context: context,
        action: 'Peg-out to parent chain',
        title: 'Submitted peg-out successfully',
        subtitle: 'TXID: $withdrawalTxid',
      );
    } catch (error) {
      log.e('could not execute peg-out: $error', error: error);

      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Peg-out to parent chain',
        title: 'Could not execute peg-out',
        subtitle: error.toString(),
      );
      // also pop the info modal
      await _router.pop();
      return;
    }
  }
}

class PegInAction extends StatelessWidget {
  const PegInAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PegInViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Peg-in from parent chain',
          endActionButton: SailButton.primary(
            'Generate new address',
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              await viewModel.generatePegInAddress();
            },
          ),
          children: [
            StaticActionField(
              label: 'Address',
              value: viewModel.pegInAddress ?? '',
              copyable: true,
            ),
          ],
        );
      }),
    );
  }
}

class PegInViewModel extends BaseViewModel {
  TestchainRPC get _rpc => GetIt.I.get<TestchainRPC>();
  final log = Logger(level: Level.debug);

  String? pegInAddress;

  PegInViewModel() {
    generatePegInAddress();
  }

  Future<void> generatePegInAddress() async {
    pegInAddress = await _rpc.mainGenerateAddress();
    notifyListeners();
  }
}
