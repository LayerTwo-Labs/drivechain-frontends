import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/utxo.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:sidesail/widgets/containers/tabs/transfer_mainchain_tab_widgets.dart';
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
                            title: 'Withdraw to parent chain',
                            category: Category.mainchain,
                            icon: Icons.remove,
                            onTap: () {
                              viewModel.pegOut(context);
                            },
                          ),
                          ActionTile(
                            title: 'Deposit from parent chain',
                            category: Category.mainchain,
                            icon: Icons.add,
                            onTap: () {
                              viewModel.pegIn(context);
                            },
                          ),
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
                    title: 'UTXOs',
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
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();

  List<UTXO> get utxos => _transactionsProvider.unspentMainchainUTXOs;

  TransferMainchainTabViewModel() {
    _transactionsProvider.addListener(notifyListeners);
  }

  void pegOut(BuildContext context) async {
    String? staticAddress;
    if (_sidechain.rpc.chain.type == SidechainType.ethereum) {
      staticAddress = formatDepositAddress('0xc96aaa54e2d44c299564da76e1cd3184a2386b8d', _sidechain.rpc.chain.slot);
    }

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return PegOutAction(
          staticAddress: staticAddress,
        );
      },
    );
  }

  void pegIn(BuildContext context) async {
    if (_sidechain.rpc.chain.type == SidechainType.ethereum) {
      return await showThemedDialog(
        context: context,
        builder: (BuildContext context) {
          return const PegInEthAction();
        },
      );
    }

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const PegInAction();
      },
    );
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
  final Future<String> Function(String address, double amount)? customSendAction;

  const SendOnParentChainAction({
    super.key,
    this.customSendAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SendViewModel(customSendAction: customSendAction),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Send on parent chain',
          endActionButton: SailButton.primary(
            'Execute send',
            disabled: viewModel.bitcoinAddressController.text.isEmpty || viewModel.bitcoinAmountController.text.isEmpty,
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.executeSendOnParentChain(context);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAddressController,
              hintText: 'Enter a parent chain address',
              autofocus: true,
            ),
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'Enter a BTC-amount',
              suffixText: viewModel.ticker,
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Fee',
              value: '${(viewModel.expectedFee ?? 0).toStringAsFixed(8)} ${viewModel.ticker}',
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

class SendViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();

  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      ((double.tryParse(bitcoinAmountController.text) ?? 0) + (expectedFee ?? 0)).toStringAsFixed(8);
  String get ticker => _sidechainContainer.rpc.chain.ticker;

  double? expectedFee;
  double? get sendAmount => double.tryParse(bitcoinAmountController.text);

  final Future<String> Function(String address, double amount)? customSendAction;

  SendViewModel({this.customSendAction}) {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(notifyListeners);
    init();
  }

  void init() async {
    await estimateFee();
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

    final address = bitcoinAddressController.text;

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
      // also pop the info modal
      await _router.pop();
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
