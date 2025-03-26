import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainSendPage extends StatelessWidget {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  AppRouter get router => GetIt.I.get<AppRouter>();

  const SidechainSendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SidechainSendViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          scrollable: true,
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
            child: Column(
              children: [
                DashboardGroup(
                  title: 'Actions',
                  children: [
                    ActionTile(
                      title: 'Send',
                      category: Category.sidechain,
                      icon: Icons.remove,
                      onTap: () async {
                        model.send(context);
                      },
                    ),
                    ActionTile(
                      title: 'Receive',
                      category: Category.sidechain,
                      icon: Icons.add,
                      onTap: () async {
                        model.receive(context);
                      },
                    ),
                  ],
                ),
                const SailSpacing(SailStyleValues.padding32),
                DashboardGroup(
                  title: 'Transactions',
                  widgetTrailing: SailText.secondary13(model.transactions.length.toString()),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final tx in model.transactions)
                          CoreTransactionView(
                            tx: tx,
                            ticker: _sidechain.rpc.chain.ticker,
                          ),
                      ],
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

class SidechainSendViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();

  List<CoreTransaction> get transactions => _transactionsProvider.sidechainTransactions;

  Binary get chain => _sideRPC.rpc.chain;

  SidechainSendViewModel() {
    _transactionsProvider.addListener(notifyListeners);
  }

  void send(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const SendOnSidechainAction();
      },
    );
  }

  void receive(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const ReceiveAction();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _transactionsProvider.removeListener(notifyListeners);
  }
}
