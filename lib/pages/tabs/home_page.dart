import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/chain_overview_card.dart';
import 'package:stacked/stacked.dart';

@auto_router.RoutePage()
class HomePage extends StatelessWidget {
  SidechainRPC get _sideRPC => GetIt.I.get<SidechainRPC>();

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = routesForChain(_sideRPC.chain);
    final theme = SailTheme.of(context);

    return auto_router.AutoTabsRouter.builder(
      homeIndex: 1,
      routes: routes,
      builder: (context, children, _) {
        final tabsRouter = auto_router.AutoTabsRouter.of(context);
        return Scaffold(
          backgroundColor: theme.colors.background,
          body: SideNav(
            child: children[tabsRouter.activeIndex],
            // assume settings tab is final tab!
            navigateToSettings: () => tabsRouter.setActiveIndex(routes.length - 1),
          ),
        );
      },
    );
  }

  List<auto_router.PageRouteInfo<dynamic>> routesForChain(Sidechain chain) {
    final preRoutes = [
      const SidechainExplorerTabRoute(),
    ];
    final postRoutes = [
      const NodeSettingsTabRoute(),
      const ThemeSettingsTabRoute(),
    ];

    List<auto_router.PageRouteInfo<dynamic>> chainRoutes = [];
    switch (chain.type) {
      case SidechainType.testChain:
        chainRoutes = [
          const DashboardTabRoute(),
          const TransferMainchainTabRoute(),
          const WithdrawalBundleTabRoute(),
          const BlindMergedMiningTabRoute(),
        ];

      case SidechainType.ethereum:
        chainRoutes = [
          const DashboardTabRoute(),
        ];
    }

    return [
      ...preRoutes,
      ...chainRoutes,
      ...postRoutes,
    ];
  }
}

class SideNav extends StatefulWidget {
  final Widget child;
  final VoidCallback navigateToSettings;

  const SideNav({
    super.key,
    required this.child,
    required this.navigateToSettings,
  });

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  SidechainRPC get _sidechain => GetIt.I.get<SidechainRPC>();

  @override
  Widget build(BuildContext context) {
    final tabsRouter = auto_router.AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomePageViewModel(),
      builder: ((context, viewModel, child) {
        final navWidgets = navForChain(_sidechain.chain, viewModel, tabsRouter);

        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SailStyleValues.padding15,
                vertical: SailStyleValues.padding20,
              ),
              child: SailColumn(
                spacing: 0,
                children: [
                  ChainOverviewCard(
                    chain: viewModel.chain,
                    confirmedBalance: viewModel.balance,
                    unconfirmedBalance: viewModel.pendingBalance,
                    highlighted: tabsRouter.activeIndex == 0,
                    currentChain: true,
                    onPressed: () {
                      tabsRouter.setActiveIndex(0);
                    },
                  ),
                  const SailSpacing(SailStyleValues.padding30),
                  for (final navEntry in navWidgets) navEntry,
                  const SailSpacing(SailStyleValues.padding50),
                  const NavCategory(category: 'Settings'),
                  NavEntry(
                    title: 'Settings',
                    icon: SailSVGAsset.iconBMMTab,
                    selected: false,
                    onPressed: () {
                      // default to second to last route (node settings)
                      tabsRouter.setActiveIndex(tabsRouter.pageCount - 2);
                    },
                  ),
                  SubNavEntryContainer(
                    // open if second to last or last route is active
                    open: tabsRouter.activeIndex == tabsRouter.pageCount - 1 ||
                        tabsRouter.activeIndex == tabsRouter.pageCount - 2,
                    subs: [
                      SubNavEntry(
                        title: 'Node Settings',
                        selected: tabsRouter.activeIndex == tabsRouter.pageCount - 2,
                        onPressed: () {
                          tabsRouter.setActiveIndex(tabsRouter.pageCount - 2);
                        },
                      ),
                      SubNavEntry(
                        title: 'Theme',
                        selected: tabsRouter.activeIndex == tabsRouter.pageCount - 1,
                        onPressed: () {
                          tabsRouter.setActiveIndex(tabsRouter.pageCount - 1);
                        },
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  NodeConnectionStatus(
                    onChipPressed: widget.navigateToSettings,
                  ),
                ],
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),
            Expanded(child: widget.child),
          ],
        );
      }),
    );
  }

  List<Widget> navForChain(Sidechain chain, HomePageViewModel viewModel, auto_router.TabsRouter tabsRouter) {
    switch (chain.type) {
      case SidechainType.testChain:
        return [
          NavEntry(
            title: '${viewModel.chain.name} Dashboard',
            icon: SailSVGAsset.iconDashboardTab,
            selected: tabsRouter.activeIndex == 1,
            onPressed: () {
              tabsRouter.setActiveIndex(1);
            },
          ),
          NavEntry(
            title: 'Mainchain Dashboard',
            icon: SailSVGAsset.iconWithdrawalBundleTab,
            selected: tabsRouter.activeIndex == 2,
            onPressed: () {
              tabsRouter.setActiveIndex(2);
            },
          ),
          SubNavEntryContainer(
            open: tabsRouter.activeIndex == 2 || tabsRouter.activeIndex == 3 || tabsRouter.activeIndex == 4,
            subs: [
              SubNavEntry(
                title: 'Withdrawal explorer',
                selected: tabsRouter.activeIndex == 3,
                onPressed: () {
                  tabsRouter.setActiveIndex(3);
                },
              ),
              SubNavEntry(
                title: 'Blind Merged Mining',
                selected: tabsRouter.activeIndex == 4,
                onPressed: () {
                  tabsRouter.setActiveIndex(4);
                },
              ),
            ],
          ),
        ];
      case SidechainType.ethereum:
        return [
          NavEntry(
            title: '${viewModel.chain.name} Dashboard',
            icon: SailSVGAsset.iconDashboardTab,
            selected: tabsRouter.activeIndex == 1,
            onPressed: () {
              tabsRouter.setActiveIndex(1);
            },
          ),
        ];
    }
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainRPC get _sideRPC => GetIt.I.get<SidechainRPC>();
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();

  bool get sidechainConnected => _sideRPC.connected;
  bool get mainchainConnected => _mainRPC.connected;

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Sidechain get chain => _sideRPC.chain;

  HomePageViewModel() {
    _sideRPC.addListener(notifyListeners);
    _mainRPC.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _sideRPC.removeListener(notifyListeners);
    _mainRPC.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
  }
}

class NodeConnectionStatus extends ViewModelWidget<HomePageViewModel> {
  final VoidCallback onChipPressed;

  const NodeConnectionStatus({super.key, required this.onChipPressed});

  @override
  Widget build(BuildContext context, HomePageViewModel viewModel) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (viewModel.sidechainConnected)
          const ConnectionSuccessChip(chain: 'sidechain')
        else
          ConnectionErrorChip(
            chain: 'sidechain',
            onPressed: onChipPressed,
          ),
        if (viewModel.mainchainConnected)
          const ConnectionSuccessChip(chain: 'mainchain')
        else
          ConnectionErrorChip(
            chain: 'mainchain',
            onPressed: onChipPressed,
          ),
      ],
    );
  }
}

class NavCategory extends StatelessWidget {
  final String category;

  const NavCategory({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: SailStyleValues.padding08, bottom: SailStyleValues.padding08),
      child: SailText.secondary12(category),
    );
  }
}

class NavEntry extends StatelessWidget {
  final String title;
  final SailSVGAsset icon;

  final bool selected;
  final VoidCallback onPressed;

  const NavEntry({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: SailScaleButton(
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
          decoration: BoxDecoration(
            color: selected ? theme.colors.actionHeader : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding08,
              vertical: SailStyleValues.padding05,
            ),
            child: SailRow(
              spacing: SailStyleValues.padding10,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SailSVG.icon(icon, width: 16),
                SailText.primary12(title, bold: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubNavEntry extends StatelessWidget {
  final String title;

  final bool selected;
  final VoidCallback onPressed;

  const SubNavEntry({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 153, maxWidth: 153),
      child: SailScaleButton(
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? theme.colors.actionHeader : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: SailColumn(
            spacing: 0,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SailStyleValues.padding08,
                  vertical: SailStyleValues.padding05,
                ),
                child: SailText.primary12(title, bold: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubNavEntryContainer extends StatelessWidget {
  final bool open;
  final List<SubNavEntry> subs;

  const SubNavEntryContainer({
    super.key,
    required this.open,
    required this.subs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (!open) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: SailStyleValues.padding30,
        top: 1,
        bottom: SailStyleValues.padding05,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: theme.colors.divider,
              width: 1.0,
            ),
          ),
        ),
        child: SailRow(
          spacing: 0,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SailSpacing(SailStyleValues.padding08),
            Column(
              children: [
                for (final sub in subs) sub,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
