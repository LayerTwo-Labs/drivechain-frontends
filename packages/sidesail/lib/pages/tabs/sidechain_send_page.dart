import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/components/dashboard_group.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
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
      builder: ((context, viewModel, child) {
        return SailPage(
          scrollable: true,
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
            child: Column(
              children: [
                DashboardGroup(
                  title: 'Actions',
                  children: [
                    ActionTile(
                      title: 'Send',
                      category: Category.sidechain,
                      icon: Icons.remove,
                      onTap: () {
                        viewModel.send(context);
                      },
                    ),
                    ActionTile(
                      title: 'Receive',
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
                  widgetTrailing: SailText.secondary13(viewModel.transactions.length.toString()),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final tx in viewModel.transactions)
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

  Sidechain get chain => _sideRPC.rpc.chain;

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
