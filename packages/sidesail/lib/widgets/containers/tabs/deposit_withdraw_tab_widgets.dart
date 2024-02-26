import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

class PegOutAction extends StatelessWidget {
  final String? staticAddress;

  const PegOutAction({
    super.key,
    this.staticAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PegOutViewModel(staticAddress: staticAddress),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Withdraw to parent chain',
          endActionButton: SailButton.primary(
            'Execute withdraw',
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
              hintText: 'Enter a parent chain bitcoin-address',
              autofocus: true,
              disabled: staticAddress != null,
            ),
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'Enter a BTC-amount',
              suffixText: 'BTC',
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Parent chain fee',
              value: '${formatBitcoin((viewModel.mainchainFee ?? 0))} BTC',
            ),
            StaticActionField(
              label: '${viewModel.sidechain.rpc.chain.name} fee',
              value: '${formatBitcoin((viewModel.sidechainFee ?? 0))} ${viewModel.sidechain.rpc.chain.ticker}',
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
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount => formatBitcoin(
        ((double.tryParse(bitcoinAmountController.text) ?? 0) + (mainchainFee ?? 0) + (sidechainFee ?? 0)),
      );

  double? sidechainFee;
  double? mainchainFee;
  double? get pegOutAmount => double.tryParse(bitcoinAmountController.text);

  final String? staticAddress;
  PegOutViewModel({this.staticAddress}) {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);

    if (staticAddress != null) {
      bitcoinAddressController.text = staticAddress!;
    }

    init();
  }

  void init() async {
    await Future.wait([estimateSidechainFee(), estimateMainchainFee()]);
  }

  void executePegOut(BuildContext context) async {
    setBusy(true);
    onPegOut(context);
    setBusy(false);
  }

  Future<void> estimateSidechainFee() async {
    sidechainFee = await sidechain.rpc.sideEstimateFee();
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

    _doPegOut(
      context,
      address,
      pegOutAmount!,
      sidechainFee!,
      mainchainFee!,
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
      'doing withdraw: $amount BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
    );

    try {
      final withdrawalTxid = await sidechain.rpc.mainSend(
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
        action: 'Withdraw to parent chain',
        title: 'Submitted withdraw successfully',
        subtitle: 'TXID: $withdrawalTxid',
      );
      // also pop the info modal
      await _router.pop();
    } catch (error) {
      log.e('could not execute withdraw: $error', error: error);

      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Withdraw to parent chain',
        title: 'Could not execute withdraw',
        subtitle: error.toString(),
      );
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
          'Deposit from parent chain',
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
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  final log = Logger(level: Level.debug);

  String? pegInAddress;

  PegInViewModel() {
    generatePegInAddress();
  }

  Future<void> generatePegInAddress() async {
    pegInAddress = await _sidechain.rpc.generateDepositAddress();
    notifyListeners();
  }
}

class PegInEthAction extends StatelessWidget {
  const PegInEthAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PegInEthViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Deposit from parent chain',
          endActionButton: SailButton.primary(
            'Deposit funds',
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              await viewModel.deposit(context);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'How much do you want to deposit?',
              suffixText: 'BTC',
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Deposit to',
              value: viewModel.pegInAddress ?? '',
              copyable: true,
            ),
            StaticActionField(
              label: '${viewModel.sidechain.rpc.chain.name} fee',
              value: '${formatBitcoin((viewModel.sidechainFee ?? 0))} BTC',
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

class PegInEthViewModel extends BaseViewModel {
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  EthereumRPC get _ethRPC => GetIt.I.get<EthereumRPC>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  final log = Logger(level: Level.debug);

  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      formatBitcoin(((double.tryParse(bitcoinAmountController.text) ?? 0) + (sidechainFee ?? 0)));

  String? pegInAddress;
  double? sidechainFee;

  PegInEthViewModel() {
    generatePegInAddress();
    bitcoinAmountController.addListener(notifyListeners);
  }

  Future<void> generatePegInAddress() async {
    pegInAddress = await _ethRPC.generateDepositAddress();
    sidechainFee = await _ethRPC.sideEstimateFee();
    notifyListeners();
  }

  Future<void> deposit(BuildContext context) async {
    if (sidechainFee == null) {
      log.e('sidechainfee was empty');
      return;
    }

    final amount = (double.tryParse(bitcoinAmountController.text) ?? 0);

    await _ethRPC.deposit(amount, sidechainFee!);

    log.i(
      'doing deposit: $amount BTC to $pegInAddress',
    );

    try {
      final success = await _ethRPC.deposit(
        amount,
        sidechainFee!,
      );

      if (!context.mounted) {
        return;
      }

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());

      if (!success) {
        throw Exception('got false response');
      }

      await successDialog(
        context: context,
        action: 'Deposit from parent chain',
        title: 'Deposited from parent-chain successfully',
        subtitle: '',
      );
      // also pop the info modal
      await _router.pop();
    } catch (error) {
      log.e('could not execute withdraw: $error', error: error);

      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Deposit from parent chain',
        title: 'Could not deposit from parent-chain',
        subtitle: error.toString(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    bitcoinAmountController.removeListener(notifyListeners);
  }
}

class DepositWithdrawHelp extends StatelessWidget {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();

  const DepositWithdrawHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return QuestionContainer(
      category: 'Deposit & Withdraw help',
      children: [
        const QuestionTitle('What are deposits and withdrawals?'),
        QuestionText(
          'You are currently connected to two blockchains. Bitcoin Core with BIP 300+301, and a sidechain called ${_sidechain.rpc.chain.name}.',
        ),
        const QuestionText(
          'Deposits and withdrawals move bitcoin from one chain to the other. A deposit adds bitcoin to the sidechain, and a withdrawal removes bitcoin from the sidechain.',
        ),
        const QuestionText(
          'When we use the word deposit or withdraw in this application, we always refer to moving coins across chains.',
        ),
        const QuestionText(
          'Only after you have deposited coins to the sidechain, can you start using it\'s special features! There\'s a special rpc called createsidechaindeposit that lets you deposit from your parent chain wallet.',
        ),
      ],
    );
  }
}

class EasyRegtestDeposit extends StatelessWidget {
  final VoidCallback depositNudgeAction;

  AppRouter get router => GetIt.I.get<AppRouter>();

  const EasyRegtestDeposit({
    super.key,
    required this.depositNudgeAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashWidgetTitleViewModel(),
      builder: ((context, viewModel, child) {
        if (viewModel.balance != 0) {
          return Container();
        }

        return SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailButton.primary(
              'Easy Deposit',
              onPressed: () async {
                try {
                  await viewModel.easyDeposit();
                } catch (err) {
                  if (!context.mounted) {
                    return;
                  }

                  await errorDialog(
                    context: context,
                    action: 'Deposit coins',
                    title: 'Could not easy-deposit coins. Try pegging in manually with \'createsidechaindeposit\'',
                    subtitle: err.toString(),
                  );
                }
              },
              loading: viewModel.isBusy,
              size: ButtonSize.small,
            ),
            SailText.secondary12(
              'Click the button to deposit coins to your sidechain',
            ),
            Expanded(child: Container()),
          ],
        );
      }),
    );
  }
}

class ZCashWidgetTitleViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool showAll = false;

  ZCashWidgetTitleViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  Future<void> easyDeposit() async {
    setBusy(true);
    // step 1, get mainchain balance
    final balance = await _mainchain.getBalance();
    final confirmedBalance = balance.$1;

    // step 2, get sidechain deposit address
    final depositAddress = await _sidechainContainer.rpc.generateDepositAddress();

    // step 3, query createsidechaindeposit with the current chain params
    final _ = await _mainchain.createSidechainDeposit(
      _sidechainContainer.rpc.chain.slot,
      depositAddress,
      confirmedBalance / 3 * 2,
    );

    // step 4 confirm the deposit
    await _mainchain.generate(22);

    setBusy(false);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
