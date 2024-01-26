import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/chain_overview_card.dart';
import 'package:stacked/stacked.dart';

class TopNav extends StatefulWidget {
  final Widget child;

  const TopNav({
    super.key,
    required this.child,
  });

  @override
  State<TopNav> createState() => _TopNavState();
}

class _TopNavState extends State<TopNav> {
  @override
  Widget build(BuildContext context) {
    final tabsRouter = auto_router.AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TopNavViewModel(),
      fireOnViewModelReadyOnce: true,
      builder: ((context, viewModel, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SailStyleValues.padding15,
                vertical: SailStyleValues.padding08,
              ),
              child: SailRow(
                spacing: SailStyleValues.padding20,
                children: [
                  ChainOverviewCard(
                    chain: viewModel.chain,
                    confirmedBalance: viewModel.balance,
                    unconfirmedBalance: null,
                    highlighted: tabsRouter.activeIndex == 0,
                    currentChain: true,
                    onPressed: RuntimeArgs.swappableChains
                        ? () {
                            tabsRouter.setActiveIndex(0);
                          }
                        : null,
                  ),
                  Expanded(child: Container()),
                  TopNavEntry(
                    title: 'Parent Chain',
                    icon: SailSVGAsset.iconMainchain,
                    selected: topTabIsSelected(tabsRouter.activeIndex, 0),
                    onPressed: () {
                      // default to second to last route (node settings)
                      tabsRouter.setActiveIndex(ParentChainHome);
                    },
                  ),
                  TopNavEntry(
                    title: 'Sidechain',
                    icon: SailSVGAsset.iconSidechain,
                    selected: topTabIsSelected(tabsRouter.activeIndex, 1),
                    onPressed: () {
                      // default to second to last route (node settings)
                      tabsRouter.setActiveIndex(viewModel.chainHome);
                    },
                  ),
                  TopNavEntry(
                    title: 'Settings',
                    icon: SailSVGAsset.iconSettings,
                    selected: topTabIsSelected(tabsRouter.activeIndex, 2),
                    onPressed: () {
                      // default to second to last route (node settings)
                      tabsRouter.setActiveIndex(tabsRouter.pageCount - 2);
                    },
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),
            Expanded(
              child: widget.child,
            ),
          ],
        );
      }),
    );
  }

  bool topTabIsSelected(int activeIndex, int parentTab) {
    switch (parentTab) {
      case 0:
        return activeIndex == ParentChainHome || activeIndex == ParentChainHome + 1;
      case 1:
        return activeIndex == TestchainHome ||
            activeIndex == TestchainHome + 1 ||
            activeIndex == TestchainHome + 2 ||
            activeIndex == EthereumHome ||
            activeIndex == ZCashHome ||
            activeIndex == ZCashHome + 1 ||
            activeIndex == ZCashHome + 2 ||
            activeIndex == ZCashHome + 3 ||
            activeIndex == ZCashHome + 4;
      case 2:
        return activeIndex == 12 || activeIndex == 13;
      default:
        return true;
    }
  }
}

class TopNavViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Sidechain get chain => _sideRPC.rpc.chain;
  int get chainHome => chain.type == SidechainType.zcash
      ? ZCashHome
      : chain.type == SidechainType.testChain
          ? TestchainHome
          : EthereumHome;

  TopNavViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
