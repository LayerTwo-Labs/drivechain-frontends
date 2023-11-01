import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class DashboardTabPage extends StatelessWidget {
  const DashboardTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomePageViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          title: '',
          scrollable: true,
          widgetTitle: Row(
            children: [
              SailText.mediumPrimary14('Balance: ${viewModel.sidechainBalance} SBTC'),
              Expanded(child: Container()),
              SailText.mediumPrimary14('Unconfirmed balance: ${viewModel.sidechainPendingBalance} SBTC'),
            ],
          ),
          body: Column(
            children: [
              DashboardGroup(
                title: 'Actions',
                children: [
                  ActionTile(
                    title: 'Peg-out to mainchain',
                    category: Category.mainchain,
                    icon: Icons.remove,
                    onTap: () {
                      viewModel.pegOut(context);
                    },
                  ),
                  ActionTile(
                    title: 'Peg-in from mainchain',
                    category: Category.mainchain,
                    icon: Icons.add,
                    onTap: () {
                      viewModel.pegIn(context);
                    },
                  ),
                  ActionTile(
                    title: 'Send on sidechain',
                    category: Category.sidechain,
                    icon: Icons.remove,
                    onTap: () {
                      viewModel.send(context);
                    },
                  ),
                  ActionTile(
                    title: 'Receive on sidechain',
                    category: Category.sidechain,
                    icon: Icons.add,
                    onTap: () {
                      viewModel.receive(context);
                    },
                  ),
                ],
              ),
              const SailSpacing(SailStyleValues.padding30),
              DashboardGroup(
                title: 'Transactions',
                titleTrailing: viewModel.transactions.length.toString(),
                endWidget: SailToggle(label: 'Show raw', value: viewModel.showRaw, onChanged: viewModel.toggleRaw),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowMaxHeight: viewModel.showRaw ? 350 : null,
                      columns: [
                        if (viewModel.showRaw) DataColumn(label: SailText.primary12('Raw')),
                        DataColumn(label: SailText.primary12('Category')),
                        DataColumn(label: SailText.primary12('Amount')),
                        DataColumn(label: SailText.primary12('Fee')),
                        DataColumn(label: SailText.primary12('TXID')),
                        DataColumn(label: SailText.primary12('Time')),
                        DataColumn(label: SailText.primary12('Address')),
                        DataColumn(label: SailText.primary12('Label')),
                        DataColumn(label: SailText.primary12('Account')),
                      ],
                      rows: viewModel.transactions.map((tx) {
                        return DataRow(
                          cells: [
                            if (viewModel.showRaw)
                              DataCell(
                                SizedBox(
                                  width: 600,
                                  child: SailText.primary12(
                                    const JsonEncoder.withIndent(' ').convert(jsonDecode(tx.raw)),
                                  ),
                                ),
                              ),
                            DataCell(SailText.primary12(tx.category)),
                            DataCell(SailText.primary12(tx.amount.toString())),
                            DataCell(SailText.primary12(tx.fee.toString())),
                            DataCell(SailText.primary12(tx.txid)),
                            DataCell(SailText.primary12(DateFormat('HH:mm MMM d').format(tx.time))),
                            DataCell(SailText.primary12(tx.address)),
                            DataCell(SailText.primary12(tx.label)),
                            DataCell(SailText.primary12(tx.account)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();

  String get sidechainBalance => _balanceProvider.balance.toStringAsFixed(8);
  String get sidechainPendingBalance => _balanceProvider.pendingBalance.toStringAsFixed(8);
  List<Transaction> get transactions => _transactionsProvider.transactions;

  bool showRaw = false;

  HomePageViewModel() {
    // by adding a listener, we subscribe to changes to the balance
    // provider. We don't use the updates for anything other than
    // showing the new value though, so we keep it simple, and just
    // pass notifyListeners of this view model directly
    _balanceProvider.addListener(notifyListeners);
    _transactionsProvider.addListener(notifyListeners);
  }

  void toggleRaw(bool value) {
    showRaw = value;
    notifyListeners();
  }

  void pegOut(BuildContext context) async {
    final theme = SailTheme.of(context);

    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const PegOutAction();
      },
    );
  }

  void pegIn(BuildContext context) async {
    final theme = SailTheme.of(context);
    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const PegInAction();
      },
    );
  }

  void send(BuildContext context) async {
    final theme = SailTheme.of(context);
    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const SendOnSidechainAction();
      },
    );
  }

  void receive(BuildContext context) async {
    final theme = SailTheme.of(context);
    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const ReceiveOnSidechainAction();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
    _transactionsProvider.removeListener(notifyListeners);
  }
}
