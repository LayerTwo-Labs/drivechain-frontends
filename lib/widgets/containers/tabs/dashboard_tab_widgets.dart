import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

class DashboardGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DashboardGroup({
    super.key,
    required this.title,
    required this.children,
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
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: SailText.mediumPrimary14(title),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
        for (final child in children) child,
      ],
    );
  }
}

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
            disabled: viewModel.bitcoinAddressController.text.isEmpty || viewModel.bitcoinAmountController.text.isEmpty,
            label: 'Execute peg-out',
            loading: viewModel.isBusy,
            size: ButtonSize.small,
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
              value: '${(viewModel.mainchainFee).toStringAsFixed(8)} BTC',
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
  AppRouter get _router => GetIt.I.get<AppRouter>();
  RPC get _rpc => GetIt.I.get<RPC>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      ((double.tryParse(bitcoinAmountController.text) ?? 0) + mainchainFee + (sidechainFee ?? 0)).toStringAsFixed(8);

  // executePegOut: estimate this
  final double mainchainFee = 0.001;
  double? sidechainFee;
  double? get pegOutAmount => double.tryParse(bitcoinAmountController.text);

  PegOutViewModel() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);
    init();
  }

  void init() async {
    await estimateSidechainFee();
  }

  void executePegOut(BuildContext context) async {
    setBusy(true);
    notifyListeners();
    onPegOut(context);
    setBusy(false);
    notifyListeners();
  }

  Future<void> estimateSidechainFee() async {
    final estimate = await _rpc.estimateSidechainFee();
    sidechainFee = estimate;
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
        title: SailText.primary14(
          'Confirm withdrawal',
        ),
        content: SailText.primary14(
          'Do you really want to peg-out?\n${bitcoinAmountController.text} BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: SailText.primary14('Cancel'),
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
              );
            },
            child: SailText.primary14(
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
  ) async {
    log.i(
      'doing peg-out: $amount BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
    );

    try {
      final withdrawalTxid = await _rpc.pegOut(
        address,
        amount,
        sidechainFee,
        mainchainFee,
      );

      if (!context.mounted) {
        return;
      }

      // refresh balance, but dont await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());

      final theme = SailTheme.of(context);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colors.background.withOpacity(0.9),
          title: SailText.primary14(
            'Success',
          ),
          content: SailText.primary14(
            'Submitted peg-out successfully! TXID: $withdrawalTxid',
          ),
          actions: [
            TextButton(
              onPressed: () => _router.popUntilRoot(),
              child: SailText.primary14('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      final theme = SailTheme.of(context);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colors.background.withOpacity(0.9),
          title: SailText.primary14(
            'Failed',
          ),
          content: SailText.primary14(
            'Could not execute peg-out ${error.toString()}',
          ),
          actions: [
            TextButton(
              onPressed: () => _router.popUntilRoot(),
              child: SailText.primary14('OK'),
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
            label: 'Generate new address',
            loading: viewModel.isBusy,
            size: ButtonSize.small,
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
  RPC get _rpc => GetIt.I.get<RPC>();
  final log = Logger(level: Level.debug);

  String? pegInAddress;

  PegInViewModel() {
    generatePegInAddress();
  }

  Future<void> generatePegInAddress() async {
    pegInAddress = await _rpc.generatePegInAddress();
    notifyListeners();
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
            disabled: viewModel.bitcoinAddressController.text.isEmpty || viewModel.bitcoinAmountController.text.isEmpty,
            label: 'Execute send',
            loading: viewModel.isBusy,
            size: ButtonSize.small,
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
  AppRouter get _router => GetIt.I.get<AppRouter>();
  RPC get _rpc => GetIt.I.get<RPC>();

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
    await estimateSidechainFee();
  }

  void executeSendOnSidechain(BuildContext context) async {
    setBusy(true);
    notifyListeners();
    onSidechainSend(context);
    setBusy(false);
    notifyListeners();

    await _router.pop();
  }

  Future<void> estimateSidechainFee() async {
    final estimate = await _rpc.estimateSidechainFee();
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

    final theme = SailTheme.of(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.background.withOpacity(0.9),
        title: SailText.primary14(
          'Confirm send',
        ),
        content: SailText.primary14(
          'Do you really want to send ${bitcoinAmountController.text} BTC to $address with $sidechainExpectedFee SC expected fee?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: SailText.primary14('Cancel'),
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
            child: SailText.primary14(
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
      final sendTXID = await _rpc.sidechainSend(
        address,
        amount,
        false,
      );
      log.i('sent sidechain withdrawal txid: $sendTXID');

      // refresh balance, but dont await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());

      if (!context.mounted) {
        return;
      }

      final theme = SailTheme.of(context);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colors.background.withOpacity(0.9),
          title: SailText.primary14(
            'Success',
          ),
          content: SailText.primary14(
            'Sent successfully! TXID: $sendTXID',
          ),
          actions: [
            TextButton(
              onPressed: () => _router.popUntilRoot(),
              child: SailText.primary14('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      final theme = SailTheme.of(context);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colors.background.withOpacity(0.9),
          title: SailText.primary14(
            'Failed',
          ),
          content: SailText.primary14(
            'Could not execute sidechain withdrawal ${error.toString()}',
          ),
          actions: [
            TextButton(
              onPressed: () => _router.popUntilRoot(),
              child: SailText.primary14('OK'),
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
            label: 'Generate new address',
            loading: viewModel.isBusy,
            size: ButtonSize.small,
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
  RPC get _rpc => GetIt.I.get<RPC>();
  final log = Logger(level: Level.debug);

  String? sidechainAddress;

  ReceiveOnSidechainViewModel() {
    generateSidechainAddress();
  }

  Future<void> generateSidechainAddress() async {
    sidechainAddress = await _rpc.generateSidechainAddress();
    notifyListeners();
  }
}
