import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/providers/transactions_provider.dart';

class DepositWithdrawHelp extends StatelessWidget {
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  const DepositWithdrawHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return QuestionContainer(
      category: 'Deposit & Withdraw help',
      children: [
        const QuestionTitle('What are deposits and withdrawals?'),
        QuestionText(
          'You are currently connected to two blockchains. Bitcoin Core with BIP 300+301, and a sidechain called ${_rpc.chain.name}.',
        ),
        const QuestionText(
          'Deposits and withdrawals move bitcoin from one chain to the other. A deposit adds bitcoin to the sidechain, and a withdrawal removes bitcoin from the sidechain.',
        ),
        const QuestionText(
          'When we use the word deposit or withdraw in this application, we always refer to moving coins across chains.',
        ),
        const QuestionText(
          "Only after you have deposited coins to the sidechain, can you start using it's special features! If you're a developer and know your way around a command line, there's a special rpc called createsidechaindeposit that lets you deposit from your parent chain wallet.",
        ),
      ],
    );
  }
}

class ZCashWidgetTitleViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool showAll = false;

  ZCashWidgetTitleViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}

class DepositWithdrawTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  final labelController = TextEditingController();

  String? depositAddress;
  double? sidechainFee;
  double? mainchainFee;

  String? depositError;
  String? withdrawError;

  double? get pegAmount => double.tryParse(bitcoinAmountController.text);
  double? get maxAmount => max(_balanceProvider.balance - (sidechainFee ?? 0) - (mainchainFee ?? 0), 0);

  String get totalBitcoinAmount => formatBitcoin(
        ((double.tryParse(bitcoinAmountController.text) ?? 0) + (mainchainFee ?? 0) + (sidechainFee ?? 0)),
      );

  DepositWithdrawTabViewModel() {
    _initControllers();
    _initFees();
    _transactionsProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
    generateDepositAddress();
  }

  void _initControllers() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(_capAmount);
  }

  Future<void> _initFees() async {
    await Future.wait([estimateSidechainFee(), estimateMainchainFee()]);
  }

  void _capAmount() {
    String currentInput = bitcoinAmountController.text;
    if (maxAmount != null && (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount!)) {
      bitcoinAmountController.text = maxAmount.toString();
      bitcoinAmountController.selection = TextSelection.fromPosition(
        TextPosition(offset: bitcoinAmountController.text.length),
      );
    }
    notifyListeners();
  }

  Future<void> estimateSidechainFee() async {
    sidechainFee = await _rpc.sideEstimateFee();
    notifyListeners();
  }

  Future<void> estimateMainchainFee() async {
    mainchainFee = 0.0001;
    notifyListeners();
  }

  Future<void> generateDepositAddress() async {
    setBusy(true);
    depositError = null;
    try {
      depositAddress = await _rpc.getDepositAddress();
    } catch (error) {
      log.e('Failed to generate deposit address', error: error);
      depositError = 'Failed to generate deposit address: ${error.toString()}';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> executePegOut(BuildContext context) async {
    if (pegAmount == null) {
      withdrawError = 'Invalid amount or fees not calculated';
      notifyListeners();
      log.e('Invalid peg out parameters');
      return;
    }

    if (sidechainFee == null) {
      await estimateSidechainFee();
      if (sidechainFee == null) {
        sidechainFee = 0.0001;
        notifyListeners();
      }
    }

    if (bitcoinAddressController.text.isEmpty) {
      withdrawError = 'Bitcoin address is required';
      notifyListeners();
      return;
    }

    setBusy(true);
    withdrawError = null;
    try {
      final withdrawalTxid = await _rpc.mainSend(
        bitcoinAddressController.text,
        pegAmount!,
        sidechainFee!,
        mainchainFee!,
      );

      if (!context.mounted) return;

      unawaited(_balanceProvider.fetch());
      unawaited(_transactionsProvider.fetch());

      await successDialog(
        context: context,
        action: 'Withdraw to parent chain',
        title: 'Submitted withdraw successfully',
        subtitle: 'TXID: $withdrawalTxid',
      );
    } catch (error) {
      log.e('Could not execute withdraw', error: error);
      withdrawError = error.toString();
      if (!context.mounted) return;

      await errorDialog(
        context: context,
        action: 'Withdraw to parent chain',
        title: 'Could not execute withdraw',
        subtitle: error.toString(),
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void castHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const DepositWithdrawHelp();
      },
    );
  }

  @override
  void dispose() {
    bitcoinAddressController.dispose();
    bitcoinAmountController.dispose();
    labelController.dispose();
    _transactionsProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class DepositTab extends StatelessWidget {
  const DepositTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DepositWithdrawTabViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Deposit from Parent Chain',
          subtitle: 'Deposit coins to the sidechain',
          error: model.depositError,
          widgetHeaderEnd: HelpButton(onPressed: () async => model.castHelp(context)),
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (model.isBusy)
                const Center(child: LoadingIndicator())
              else ...[
                SailTextField(
                  controller: TextEditingController(text: model.depositAddress),
                  hintText: 'Generating deposit address...',
                  readOnly: true,
                  suffixWidget: CopyButton(
                    text: model.depositAddress ?? '',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class WithdrawTab extends ViewModelWidget<DepositWithdrawTabViewModel> {
  const WithdrawTab({super.key});

  @override
  Widget build(BuildContext context, DepositWithdrawTabViewModel viewModel) {
    return SailCard(
      title: 'Withdraw to Parent Chain',
      subtitle: 'Withdraw bitcoin from the sidechain to the parent chain',
      error: viewModel.withdrawError,
      child: Column(
        children: [
          SailTextField(
            label: 'Pay To',
            controller: viewModel.bitcoinAddressController,
            hintText: 'Enter a L1 bitcoin-address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
            size: TextFieldSize.small,
            suffixWidget: PasteButton(
              onPaste: (text) {
                viewModel.bitcoinAddressController.text = text;
              },
            ),
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
                            controller: viewModel.bitcoinAmountController,
                            suffixWidget: SailButton(
                              label: 'MAX',
                              variant: ButtonVariant.link,
                              onPressed: () async {
                                if (viewModel.maxAmount != null) {
                                  viewModel.bitcoinAmountController.text = viewModel.maxAmount.toString();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SailStyleValues.padding16),
                    SailTextField(
                      label: 'Label (optional)',
                      controller: viewModel.labelController,
                      hintText: 'Enter a label',
                      size: TextFieldSize.small,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailButton(
                    label: 'Send',
                    onPressed: () => viewModel.executePegOut(context),
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    variant: ButtonVariant.secondary,
                    label: 'Clear All',
                    onPressed: () async {
                      viewModel.bitcoinAddressController.clear();
                      viewModel.bitcoinAmountController.clear();
                      viewModel.labelController.clear();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
