import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/pages/tabs/dashboard_tab_page.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
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
              child: Column(
                children: [
                  DashboardGroup(
                    title: 'Actions',
                    children: [
                      ActionTile(
                        title: 'Peg-out to parent chain',
                        category: Category.mainchain,
                        icon: Icons.remove,
                        onTap: () {
                          viewModel.pegOut(context);
                        },
                      ),
                      ActionTile(
                        title: 'Peg-in from parent chain',
                        category: Category.mainchain,
                        icon: Icons.add,
                        onTap: () {
                          viewModel.pegIn(context);
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.transactions.length,
                            itemBuilder: (context, index) => TxView(
                              key: ValueKey<String>(viewModel.transactions[index].txid),
                              tx: viewModel.transactions[index],
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

  List<CoreTransaction> get transactions => _transactionsProvider.mainchainTransactions;

  TransferMainchainTabViewModel() {
    _transactionsProvider.addListener(notifyListeners);
  }

  void pegOut(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const PegOutAction();
      },
    );
  }

  void pegIn(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const PegInAction();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _transactionsProvider.removeListener(notifyListeners);
  }
}
