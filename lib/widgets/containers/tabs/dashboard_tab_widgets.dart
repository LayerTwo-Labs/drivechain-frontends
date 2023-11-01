import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/routing/router.dart';
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
            label: 'Execute peg-out',
            loading: viewModel.isBusy,
            size: ButtonSize.small,
            onPressed: () async {
              viewModel.executePegOut();
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
            const StaticActionField(
              label: 'Mainchain fee',
              value: 'TBD BTC',
            ),
            const StaticActionField(
              label: 'Sidechain fee',
              value: 'TBD BTC',
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
  AppRouter get _router => GetIt.I.get<AppRouter>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount => (double.tryParse(bitcoinAmountController.text) ?? 0).toStringAsFixed(8);

  PegOutViewModel() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);
  }

  void executePegOut() async {
    setBusy(true);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1), () {});

    setBusy(false);
    notifyListeners();

    await _router.pop();
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
          'Peg-in to mainchain',
          endActionButton: SailButton.primary(
            label: 'Generate new address',
            loading: viewModel.isBusy,
            size: ButtonSize.small,
            onPressed: () async {
              viewModel.generateNewAddress();
            },
          ),
          children: const [
            StaticActionField(
              label: 'Deposit bitcoin to this address',
              value: 'TBD bitcoin-address',
            ),
          ],
        );
      }),
    );
  }
}

class PegInViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);

  PegInViewModel();

  void generateNewAddress() async {
    setBusy(true);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1), () {});

    setBusy(false);
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
            label: 'Execute withdrawal',
            loading: viewModel.isBusy,
            size: ButtonSize.small,
            onPressed: () async {
              viewModel.executeSendOnSidechain();
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
            const StaticActionField(
              label: 'Fee',
              value: 'TBD BTC',
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
  AppRouter get _router => GetIt.I.get<AppRouter>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount => (double.tryParse(bitcoinAmountController.text) ?? 0).toStringAsFixed(8);

  SendOnSidechainViewModel() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);
  }

  void executeSendOnSidechain() async {
    setBusy(true);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1), () {});

    setBusy(false);
    notifyListeners();

    await _router.pop();
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
              viewModel.generateNewAddress();
            },
          ),
          children: const [
            StaticActionField(
              label: 'Deposit sidechain-coins to this address',
              value: 'TBD bitcoin-address',
            ),
          ],
        );
      }),
    );
  }
}

class ReceiveOnSidechainViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);

  ReceiveOnSidechainViewModel();

  void generateNewAddress() async {
    setBusy(true);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1), () {});

    setBusy(false);
    notifyListeners();
  }
}
