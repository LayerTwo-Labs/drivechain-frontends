import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/chain_overview_card.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainExplorerTabPage extends StatelessWidget {
  const SidechainExplorerTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SidechainExplorerTabViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          title: '',
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
                          onPressed: () {
                            viewModel.setSidechainRPC(TestSidechain());
                          },
                        ),
                        ChainOverviewCard(
                          chain: EthereumSidechain(),
                          confirmedBalance: viewModel.balance,
                          unconfirmedBalance: viewModel.pendingBalance,
                          highlighted: false,
                          currentChain: viewModel.chain.type == SidechainType.ethereum,
                          onPressed: () {
                            viewModel.setSidechainRPC(EthereumSidechain());
                          },
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
  SidechainRPC get _sideRPC => GetIt.I.get<SidechainRPC>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Sidechain get chain => _sideRPC.chain;

  SidechainExplorerTabViewModel() {
    // by adding a listener, we subscribe to changes to the balance
    // provider. We don't use the updates for anything other than
    // showing the new value though, so we keep it simple, and just
    // pass notifyListeners of this view model directly
    _balanceProvider.addListener(notifyListeners);
    _sideRPC.addListener(notifyListeners);
  }

  void setSidechainRPC(Sidechain chain) {
    _sideRPC.setChain(chain);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
    _sideRPC.removeListener(notifyListeners);
  }
}
