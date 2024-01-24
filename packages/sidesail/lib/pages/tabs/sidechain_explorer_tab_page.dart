import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/theme_settings.dart';
import 'package:sidesail/widgets/containers/chain_overview_card.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainExplorerTabPage extends StatelessWidget {
  const SidechainExplorerTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = SailApp.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SidechainExplorerTabViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          body: SailColumn(
            spacing: SailStyleValues.padding30,
            children: [
              DashboardGroup(
                title: 'Your installed chains',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(SailStyleValues.padding30),
                    child: SailRow(
                      spacing: SailStyleValues.padding30,
                      children: [
                        ChainOverviewCard(
                          chain: TestSidechain(),
                          confirmedBalance: viewModel.balance,
                          unconfirmedBalance: viewModel.pendingBalance,
                          highlighted: false,
                          currentChain: viewModel.chain.type == SidechainType.testChain,
                          onPressed: () => viewModel.setSidechain(TestSidechain(), app),
                        ),
                        ChainOverviewCard(
                          chain: EthereumSidechain(),
                          confirmedBalance: viewModel.balance,
                          unconfirmedBalance: viewModel.pendingBalance,
                          highlighted: false,
                          currentChain: viewModel.chain.type == SidechainType.ethereum,
                          onPressed: () => viewModel.setSidechain(EthereumSidechain(), app),
                        ),
                        ChainOverviewCard(
                          chain: ZCashSidechain(),
                          confirmedBalance: viewModel.balance,
                          unconfirmedBalance: viewModel.pendingBalance,
                          highlighted: false,
                          currentChain: viewModel.chain.type == SidechainType.zcash,
                          onPressed: () => viewModel.setSidechain(ZCashSidechain(), app),
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

  Sidechain get chain => sidechain.rpc.chain;

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
