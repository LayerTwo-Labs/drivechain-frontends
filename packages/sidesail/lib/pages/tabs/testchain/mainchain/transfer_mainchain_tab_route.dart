import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class TransferMainchainTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const TransferMainchainTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TransferMainchainTabViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
              child: SailColumn(
                spacing: SailStyleValues.padding30,
                children: [
                  SailColumn(
                    spacing: SailStyleValues.padding30,
                    children: [
                      DashboardGroup(
                        title: 'Actions',
                        children: [
                          ActionTile(
                            title: 'Send on parent chain',
                            category: Category.mainchain,
                            icon: Icons.remove,
                            onTap: () {
                              viewModel.send(context);
                            },
                          ),
                          ActionTile(
                            title: 'Receive on parent chain',
                            category: Category.mainchain,
                            icon: Icons.add,
                            onTap: () {
                              viewModel.receive(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  DashboardGroup(
                    title: 'Your UTXOs',
                    widgetTrailing: SailText.secondary13(viewModel.utxos.length.toString()),
                    children: [
                      SailColumn(
                        spacing: 0,
                        withDivider: true,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.utxos.length,
                            itemBuilder: (context, index) => UTXOView(
                              key: ValueKey<String>(viewModel.utxos[index].txid),
                              utxo: viewModel.utxos[index],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class TransferMainchainTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();

  List<UTXO> get utxos => _transactionsProvider.unspentMainchainUTXOs;

  TransferMainchainTabViewModel() {
    _transactionsProvider.addListener(notifyListeners);
  }

  void send(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const SendOnParentChainAction();
      },
    );
  }

  void receive(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return ReceiveAction(
          customTitle: 'Receive on parent chain',
          customReceiveAction: () async {
            return await _mainRPC.getNewAddress();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _transactionsProvider.removeListener(notifyListeners);
  }
}

class SendOnParentChainAction extends StatelessWidget {
  final double? maxAmount;
  final Future<String> Function(String address, double amount)? customSendAction;

  const SendOnParentChainAction({
    super.key,
    this.maxAmount,
    this.customSendAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SendViewModel(
        customSendAction: customSendAction,
        maxAmount: maxAmount,
      ),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Send on parent chain',
          endActionButton: SailButton.primary(
            'Execute send',
            disabled: viewModel.addressController.text.isEmpty || viewModel.amountController.text.isEmpty,
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.executeSendOnParentChain(context);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.addressController,
              hintText: 'Enter a parent chain address',
              autofocus: true,
            ),
            LargeEmbeddedInput(
              controller: viewModel.amountController,
              hintText: 'Enter a BTC-amount',
              suffixText: 'BTC',
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Fee',
              value: (formatBitcoin(viewModel.expectedFee ?? 0)),
            ),
            StaticActionField(
              label: 'Total amount',
              value: viewModel.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class SendViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();

  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();

  final addressController = TextEditingController();
  final amountController = TextEditingController();
  String get totalBitcoinAmount => formatBitcoin(((double.tryParse(amountController.text) ?? 0) + (expectedFee ?? 0)));
  String get ticker => _sidechainContainer.rpc.chain.ticker;

  double? expectedFee;
  double? get sendAmount => double.tryParse(amountController.text);

  final Future<String> Function(String address, double amount)? customSendAction;
  final double? maxAmount;

  SendViewModel({
    this.customSendAction,
    this.maxAmount,
  }) {
    addressController.addListener(notifyListeners);
    amountController.addListener(_capAmount);
    init();
  }

  void init() async {
    await estimateFee();
  }

  void _capAmount() {
    String currentInput = amountController.text;

    if (maxAmount != null && (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount!)) {
      amountController.text = maxAmount.toString();
      amountController.selection = TextSelection.fromPosition(TextPosition(offset: amountController.text.length));
    } else {
      notifyListeners();
    }
  }

  void executeSendOnParentChain(BuildContext context) async {
    setBusy(true);
    onParentSend(context);
    setBusy(false);
  }

  Future<void> estimateFee() async {
    final estimate = await _rpc.estimateFee();
    expectedFee = estimate;
    notifyListeners();
  }

  void onParentSend(BuildContext context) async {
    if (sendAmount == null) {
      log.e('withdrawal amount was empty');
      return;
    }
    if (expectedFee == null) {
      log.e('sidechain fee was empty');
      return;
    }

    final address = addressController.text;

    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    _doSend(
      context,
      address,
      sendAmount!,
    );
  }

  void _doSend(
    BuildContext context,
    String address,
    double amount,
  ) async {
    log.i(
      'doing parent chain transfer: $amount $ticker to $address with $expectedFee SC fee',
    );

    try {
      final sendTXID = await _send(address, amount);
      log.i('sent parent chain transfer txid: $sendTXID sendTXID');

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_transactionsProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Send on parent chain',
        title: 'You sent $amount BTC to $address',
        subtitle: 'TXID: $sendTXID',
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Send on parent chain',
        title: 'Could not execute transfer',
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

    return await _rpc.send(
      address,
      amount,
      false,
    );
  }
}
