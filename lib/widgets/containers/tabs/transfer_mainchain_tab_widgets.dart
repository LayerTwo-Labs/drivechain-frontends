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
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
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
          'Peg-out to mainchain',
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
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAddressController,
              hintText: 'Enter a mainchain bitcoin-address',
            ),
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'Enter a BTC-amount',
              suffixText: 'BTC',
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Mainchain fee',
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
  SidechainRPC get _testchain => GetIt.I.get<SidechainRPC>();
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

    final theme = SailTheme.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.background.withOpacity(0.9),
        title: SailText.primary13(
          'Confirm withdrawal',
        ),
        content: SailText.primary13(
          'Do you really want to peg-out?\n${bitcoinAmountController.text} BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
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
              _doPegOut(
                context,
                address,
                pegOutAmount!,
                sidechainFee!,
                mainchainFee!,
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

      final theme = SailTheme.of(context);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colors.background.withOpacity(0.9),
          title: SailText.primary13(
            'Success',
          ),
          content: SailText.primary13(
            'Submitted peg-out successfully! TXID: $withdrawalTxid',
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
      log.e('could not execute peg-out: $error', error: error);

      if (!context.mounted) {
        return;
      }

      final theme = SailTheme.of(context);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colors.background.withOpacity(0.9),
          title: SailText.primary13(
            'Failed',
          ),
          content: SailText.primary13(
            'Could not execute peg-out: ${error.toString()}',
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

class PegInAction extends StatelessWidget {
  const PegInAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PegInViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Peg-in from mainchain',
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
  SidechainRPC get _rpc => GetIt.I.get<SidechainRPC>();
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
