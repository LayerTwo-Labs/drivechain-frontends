import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/chain_overview_card.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainExplorerTabPage extends StatelessWidget {
  const SidechainExplorerTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = SailApp.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SidechainExplorerTabViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          body: SailColumn(
            spacing: SailStyleValues.padding32,
            children: [
              DashboardGroup(
                title: 'Your installed chains',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(SailStyleValues.padding32),
                    child: SailRow(
                      spacing: SailStyleValues.padding32,
                      children: [
                        ChainOverviewCard(
                          chain: TestSidechain(),
                          confirmedBalance: model.balance,
                          unconfirmedBalance: model.pendingBalance,
                          highlighted: false,
                          currentChain: model.chain == TestSidechain(),
                          onPressed: () => model.setSidechain(TestSidechain(), app),
                          inBottomNav: false,
                        ),
                        ChainOverviewCard(
                          chain: EthereumSidechain(),
                          confirmedBalance: model.balance,
                          unconfirmedBalance: model.pendingBalance,
                          highlighted: false,
                          currentChain: model.chain == EthereumSidechain(),
                          onPressed: () => model.setSidechain(EthereumSidechain(), app),
                          inBottomNav: false,
                        ),
                        ChainOverviewCard(
                          chain: ZCashSidechain(),
                          confirmedBalance: model.balance,
                          unconfirmedBalance: model.pendingBalance,
                          highlighted: false,
                          currentChain: model.chain == ZCashSidechain(),
                          onPressed: () => model.setSidechain(ZCashSidechain(), app),
                          inBottomNav: false,
                        ),
                      ],
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

class SidechainExplorerTabViewModel extends BaseViewModel {
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  ClientSettings get _clientSettings => GetIt.I.get<ClientSettings>();
  Logger get log => GetIt.I.get<Logger>();
  SailThemeValues theme = SailThemeValues.light;

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Binary get chain => sidechain.rpc.chain;

  SidechainExplorerTabViewModel() {
    _balanceProvider.addListener(notifyListeners);
    sidechain.addListener(notifyListeners);
    _init();
  }

  Future<void> _init() async {
    theme = (await _clientSettings.getValue(ThemeSetting())).value;
  }

  void setSidechain(Sidechain chain, SailAppState sailApp) async {
    setBusy(true);
    final subRPC = await findSubRPC(chain);

    log.d('setting sidechain RPC to "${subRPC.chain.name}"');
    sidechain.rpc = subRPC;

    setBusy(false);
    notifyListeners();
    await sailApp.loadTheme(theme);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
    sidechain.removeListener(notifyListeners);
  }
}
