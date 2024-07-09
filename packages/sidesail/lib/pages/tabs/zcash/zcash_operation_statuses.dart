import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/components/dashboard_group.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_transfer_page.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/tabs/zcash_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashOperationStatusesTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashOperationStatusesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => OperationStatusesiewModel(),
      builder: ((context, viewModel, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return SailPage(
          scrollable: true,
          widgetTitle: ZCashWidgetTitle(
            depositNudgeAction: () => tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
            child: SailColumn(
              spacing: SailStyleValues.padding30,
              children: [
                DashboardGroup(
                  title: 'Operation statuses',
                  widgetEnd: SailRow(
                    spacing: SailStyleValues.padding12,
                    children: [
                      SailTextButton(
                        label: 'Clear',
                        onPressed: () => viewModel.clear(),
                      ),
                      HelpButton(onPressed: () => viewModel.operationHelp(context)),
                    ],
                  ),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.operations.length,
                          itemBuilder: (context, index) => OperationView(
                            key: ValueKey<String>(viewModel.operations[index].id),
                            tx: viewModel.operations[index],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                DashboardGroup(
                  title: 'Transparent transactions',
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
                          itemBuilder: (context, index) => CoreTransactionView(
                            key: ValueKey<String>(viewModel.transactions[index].txid),
                            tx: viewModel.transactions[index],
                            ticker: viewModel.chain.ticker,
                          ),
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

class OperationStatusesiewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();

  List<OperationStatus> get operations => _zcashProvider.operations.reversed.toList();
  List<CoreTransaction> get transactions => _zcashProvider.transparentTransactions;
  Sidechain get chain => sidechain.rpc.chain;

  OperationStatusesiewModel() {
    _zcashProvider.addListener(notifyListeners);
  }

  Future<void> clear() async {
    _zcashProvider.operations = List.empty();
    notifyListeners();
  }

  void operationHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const OperationHelp();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _zcashProvider.removeListener(notifyListeners);
  }
}
