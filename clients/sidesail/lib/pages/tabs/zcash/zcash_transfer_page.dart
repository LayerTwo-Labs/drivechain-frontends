import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:sidesail/widgets/containers/tabs/zcash_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashTransferTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashTransferTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashTransferTabViewModel(),
      builder: ((context, model, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return SailPage(
          scrollable: true,
          widgetTitle: ZCashWidgetTitle(
            depositNudgeAction: () => tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
            child: SailColumn(
              spacing: SailStyleValues.padding32,
              children: [
                SailRow(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 0,
                  children: [
                    Flexible(
                      child: SailColumn(
                        spacing: SailStyleValues.padding32,
                        children: [
                          DashboardGroup(
                            title: 'Transparent coins',
                            children: [
                              ActionTile(
                                title: 'Send transparent coins',
                                category: Category.sidechain,
                                icon: Icons.remove,
                                onTap: () {
                                  model.sendTransparent(context);
                                },
                              ),
                              ActionTile(
                                title: 'Receive transparent coins',
                                category: Category.sidechain,
                                icon: Icons.remove,
                                onTap: () {
                                  model.receiveTransparent(context);
                                },
                              ),
                            ],
                          ),
                          DashboardGroup(
                            title: 'Transparent UTXOs',
                            widgetTrailing: SailText.secondary13(model.transparentUTXOs.length.toString()),
                            widgetEnd: SailToggle(
                              label: 'Hide dust UTXOs',
                              value: model.hideDust,
                              onChanged: (to) => model.setHideDust(to),
                            ),
                            children: [
                              SailColumn(
                                spacing: 0,
                                withDivider: true,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final utxo in model.transparentUTXOs)
                                    UnshieldedUTXOView(
                                      utxo: utxo,
                                      shieldAction: null,
                                      meltMode: true,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: theme.colors.divider,
                    ),
                    Flexible(
                      child: SailColumn(
                        spacing: SailStyleValues.padding32,
                        children: [
                          DashboardGroup(
                            title: 'Private coins',
                            children: [
                              ActionTile(
                                title: 'Send private coins',
                                category: Category.sidechain,
                                icon: Icons.remove,
                                onTap: () {
                                  model.sendPrivate(context);
                                },
                              ),
                              ActionTile(
                                title: 'Receive private coins',
                                category: Category.sidechain,
                                icon: Icons.add,
                                onTap: () {
                                  model.receivePrivate(context);
                                },
                              ),
                            ],
                          ),
                          DashboardGroup(
                            title: 'Private UTXOs',
                            widgetTrailing: SailText.secondary13(model.shieldedUTXOs.length.toString()),
                            children: [
                              SailColumn(
                                spacing: 0,
                                withDivider: true,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final utxo in model.shieldedUTXOs)
                                    ShieldedUTXOView(
                                      utxo: utxo,
                                      deshieldAction: null,
                                      castMode: true,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ZCashTransferTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();

  String get zcashAddress => _zcashProvider.zcashAddress;
  List<OperationStatus> get operations => _zcashProvider.operations.reversed.toList();
  List<UnshieldedUTXO> get transparentUTXOs =>
      _zcashProvider.unshieldedUTXOs.where((u) => !hideDust || u.amount > zcashFee).toList();
  List<ShieldedUTXO> get shieldedUTXOs => _zcashProvider.shieldedUTXOs;

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool hideDust = false;

  void setHideDust(bool to) {
    hideDust = to;
    notifyListeners();
  }

  ZCashTransferTabViewModel() {
    _zcashProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
    _transactionsProvider.addListener(notifyListeners);
  }

  void sendPrivate(BuildContext context) async {
    final privateBalance = shieldedUTXOs.fold(0.0, (sum, elem) => sum + elem.amount);

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return SendOnSidechainAction(
          maxAmount: max(privateBalance - _zcashProvider.sideFee, 0),
        );
      },
    );
  }

  void receivePrivate(BuildContext context) async {
    final provider = GetIt.I.get<ZCashProvider>();

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return ReceiveAction(
          customTitle: 'Receive private coins',
          customReceiveAction: () => provider.rpc.getPrivateAddress(),
          initialAddress: provider.zcashAddress,
        );
      },
    );
  }

  void sendTransparent(BuildContext context) async {
    final transparentBalance = transparentUTXOs.fold(0.0, (sum, elem) => sum + elem.amount);

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return SendOnSidechainAction(
          maxAmount: transparentBalance,
          customSendAction: (address, amount) async {
            return await _zcashProvider.rpc.sendTransparent(
              address,
              amount,
              true,
            );
          },
        );
      },
    );
  }

  void receiveTransparent(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return ReceiveAction(
          customReceiveAction: () async {
            return await _zcashProvider.rpc.getSideAddress();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _zcashProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
    _transactionsProvider.removeListener(notifyListeners);
  }
}

class ZCashWidgetTitle extends StatelessWidget {
  final VoidCallback depositNudgeAction;

  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashWidgetTitle({
    super.key,
    required this.depositNudgeAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashWidgetTitleViewModel(),
      builder: ((context, model, child) {
        if (model.balance != 0) {
          return SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.secondary13('Your ZCash-address: ${model.zcashAddress}'),
              Expanded(child: Container()),
            ],
          );
        }

        return SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailButton.primary(
              'Deposit coins',
              onPressed: () async {
                try {
                  depositNudgeAction();
                } catch (err) {
                  if (!context.mounted) {
                    return;
                  }

                  await errorDialog(
                    context: context,
                    action: 'Deposit coins',
                    title: 'Could not move to deposit tab',
                    subtitle: err.toString(),
                  );
                }
              },
              loading: model.isBusy,
              size: ButtonSize.small,
            ),
            SailText.secondary12(
              'To get started, you must deposit coins to your sidechain. Deposit on the Parent Chain tab',
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
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  String get zcashAddress => _zcashProvider.zcashAddress;
  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool showAll = false;

  ZCashWidgetTitleViewModel() {
    _zcashProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _zcashProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
  }
}
