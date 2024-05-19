import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
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
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();

  @override
  Widget build(BuildContext context) {
    final tabsRouter = auto_router.AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TopNavViewModel(),
      fireOnViewModelReadyOnce: true,
      builder: ((context, viewModel, child) {
        final sidechainNav = _navForSidechain(_sidechain.rpc.chain, viewModel, tabsRouter);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SailStyleValues.padding15,
                vertical: SailStyleValues.padding05,
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
                  SailColumn(
                    spacing: SailStyleValues.padding10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SailText.secondary12('Parent Chain'),
                      SailRow(
                        spacing: 0,
                        children: [
                          NavEntry(
                            title: 'Deposit/Withdraw',
                            selected: tabsRouter.activeIndex == Tabs.ParentChainPeg.index,
                            onPressed: () {
                              tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index);
                            },
                          ),
                          NavEntry(
                            title: 'Send',
                            selected: tabsRouter.activeIndex == Tabs.ParentChainTransfer.index,
                            onPressed: () {
                              tabsRouter.setActiveIndex(Tabs.ParentChainTransfer.index);
                            },
                          ),
                          if (_sidechain.rpc.chain.type == SidechainType.testChain)
                            NavEntry(
                              title: 'Blind Merged Mining',
                              selected: tabsRouter.activeIndex == Tabs.ParentChainBMM.index,
                              onPressed: () {
                                tabsRouter.setActiveIndex(Tabs.ParentChainBMM.index);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: theme.colors.divider,
                      ),
                    ),
                  ),
                  SailColumn(
                    spacing: SailStyleValues.padding10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SailText.secondary12('Sidechain'),
                      SailRow(
                        spacing: 0,
                        children: [
                          ...sidechainNav,
                        ],
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  NavEntry(
                    title: '',
                    icon: SailSVGAsset.iconSettings,
                    selected: tabsRouter.activeIndex == Tabs.SettingsHome.index,
                    onPressed: () {
                      // default to second to last route (node settings)
                      tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
                    },
                  ),
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

  List<Widget> _navForSidechain(
    Sidechain chain,
    TopNavViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    switch (chain.type) {
      case SidechainType.testChain:
        return [
          SubNavEntryContainer(
            open: true,
            subs: [
              NavEntry(
                title: 'Send',
                selected: tabsRouter.activeIndex == Tabs.SidechainSend.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.SidechainSend.index);
                },
              ),
              NavEntry(
                title: 'Console',
                selected: tabsRouter.activeIndex == Tabs.TestchainConsole.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.TestchainConsole.index);
                },
              ),
            ],
          ),
        ];
      case SidechainType.ethereum:
        return [
          SubNavEntryContainer(
            open: true,
            subs: [
              NavEntry(
                title: 'Console',
                selected: tabsRouter.activeIndex == Tabs.EthereumConsole.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.EthereumConsole.index);
                },
              ),
            ],
          ),
        ];

      case SidechainType.zcash:
        return [
          SubNavEntryContainer(
            open: true,
            subs: [
              NavEntry(
                title: 'Send',
                selected: tabsRouter.activeIndex == Tabs.ZCashTransfer.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.ZCashTransfer.index);
                },
              ),
              NavEntry(
                title: 'Shield/Deshield',
                selected: tabsRouter.activeIndex == Tabs.ZCashShieldDeshield.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.ZCashShieldDeshield.index);
                },
              ),
              NavEntry(
                title: 'Melt/Cast',
                selected: tabsRouter.activeIndex == Tabs.ZCashMeltCast.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.ZCashMeltCast.index);
                },
              ),
              NavEntry(
                title: 'Operation Statuses',
                selected: tabsRouter.activeIndex == Tabs.ZCashOperationStatuses.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.ZCashOperationStatuses.index);
                },
              ),
              NavEntry(
                title: 'Console',
                selected: tabsRouter.activeIndex == Tabs.ZCashConsole.index,
                onPressed: () {
                  tabsRouter.setActiveIndex(Tabs.ZCashConsole.index);
                },
              ),
            ],
          ),
        ];
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

  TopNavViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
