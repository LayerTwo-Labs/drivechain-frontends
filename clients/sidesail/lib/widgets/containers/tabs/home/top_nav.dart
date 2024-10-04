import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';
import 'package:sidesail/config/chains.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
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
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();

  @override
  Widget build(BuildContext context) {
    final tabsRouter = auto_router.AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TopNavViewModel(),
      fireOnViewModelReadyOnce: true,
      builder: ((context, model, child) {
        final sidechainNav = _navForSidechain(_sidechain.rpc.chain, model, tabsRouter);
        final trailingSidechainNav = _navForSidechainTrailing(_sidechain.rpc.chain, model, tabsRouter);

        return Column(
          children: [
            SailRow(
              spacing: 0,
              children: [
                NavContainer(
                  title: 'Parent Chain',
                  subs: [
                    QtTab(
                      label: 'Deposit/Withdraw',
                      active: tabsRouter.activeIndex == Tabs.ParentChainPeg.index,
                      onTap: () {
                        tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index);
                      },
                      icon: SailSVG.icon(SailSVGAsset.iconTabPeg),
                    ),
                    if (_sidechain.rpc.chain.type == ChainType.testChain)
                      QtTab(
                        label: 'Withdrawal Explorer',
                        active: tabsRouter.activeIndex == Tabs.ParentChainWithdrawalExplorer.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.ParentChainWithdrawalExplorer.index);
                        },
                        icon: SailSVG.icon(SailSVGAsset.iconTabWithdrawalExplorer),
                      ),
                    if (_sidechain.rpc.chain.type == ChainType.testChain)
                      QtTab(
                        label: 'Blind Merged Mining',
                        active: tabsRouter.activeIndex == Tabs.ParentChainBMM.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.ParentChainBMM.index);
                        },
                        icon: SailSVG.icon(SailSVGAsset.iconTabBMM),
                      ),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: theme.colors.icon.withOpacity(0.2),
                  ),
                ),
                NavContainer(
                  title: 'Sidechain',
                  subs: sidechainNav,
                ),
                SizedBox(
                  height: 50,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: theme.colors.icon.withOpacity(0.2),
                  ),
                ),
                NavContainer(
                  title: 'General',
                  subs: trailingSidechainNav,
                ),
                Expanded(child: Container()),
                const ToggleThemeButton(),
              ],
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

  List<QtTab> _navForSidechain(
    Sidechain chain,
    TopNavViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    switch (chain.type) {
      case ChainType.testChain:
        return [
          QtTab(
            label: 'Send',
            active: tabsRouter.activeIndex == Tabs.SidechainSend.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.SidechainSend.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabSidechainSend),
          ),
        ];
      case ChainType.ethereum:
        return [
          QtTab(
            label: 'Console',
            active: tabsRouter.activeIndex == Tabs.EthereumConsole.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.EthereumConsole.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabConsole),
          ),
        ];

      case ChainType.zcash:
        return [
          QtTab(
            label: 'Send',
            active: tabsRouter.activeIndex == Tabs.ZCashTransfer.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashTransfer.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabSidechainSend),
          ),
          QtTab(
            label: 'Shield/Deshield',
            active: tabsRouter.activeIndex == Tabs.ZCashShieldDeshield.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashShieldDeshield.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabZCashShieldDeshield),
          ),
          QtTab(
            label: 'Melt/Cast',
            active: tabsRouter.activeIndex == Tabs.ZCashMeltCast.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashMeltCast.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabZCashMeltCast),
          ),
          QtTab(
            label: 'Operation Statuses',
            active: tabsRouter.activeIndex == Tabs.ZCashOperationStatuses.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashOperationStatuses.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabZCashOperationStatuses),
          ),
        ];

      case ChainType.parentchain:
        return [];
    }
  }

  List<QtTab> _navForSidechainTrailing(
    Chain chain,
    TopNavViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    List<QtTab> trailing = [];

    switch (chain.type) {
      case ChainType.testChain:
        trailing = [
          QtTab(
            label: 'Console',
            active: tabsRouter.activeIndex == Tabs.TestchainConsole.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.TestchainConsole.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabConsole),
          ),
        ];
        break;

      case ChainType.ethereum:
        break;

      case ChainType.zcash:
        trailing = [
          QtTab(
            label: 'Console',
            active: tabsRouter.activeIndex == Tabs.ZCashConsole.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashConsole.index);
            },
            icon: SailSVG.icon(SailSVGAsset.iconTabConsole),
          ),
        ];
        break;

      case ChainType.parentchain:
        break;
    }

    return [
      ...trailing,
      QtTab(
        label: 'Settings',
        active: tabsRouter.activeIndex == Tabs.SettingsHome.index,
        onTap: () {
          // default to second to last route (node settings)
          tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
        },
        icon: SailSVG.icon(SailSVGAsset.iconTabSettings),
      ),
    ];
  }
}

class TopNavViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Chain get chain => _sideRPC.rpc.chain;

  TopNavViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
