import 'package:auto_route/auto_route.dart';
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

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return AutoTabsRouter.builder(
      homeIndex: 1,
      routes: const [
        SidechainExplorerTabRoute(),
        DashboardTabRoute(),
        TransferMainchainTabRoute(),
        WithdrawalBundleTabRoute(),
        BlindMergedMiningTabRoute(),
        SettingsTabRoute(),
      ],
      builder: (context, children, _) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          backgroundColor: theme.colors.background,
          body: SideNav(
            child: children[tabsRouter.activeIndex],
            navigateToSettings: () => tabsRouter.setActiveIndex(5),
          ),
        );
      },
    );
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
  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomePageViewModel(),
      builder: ((context, viewModel, child) {
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
                    icon: SailSVGAsset.iconDashboardTab,
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
                  NavEntry(
                    title: 'Settings',
                    icon: SailSVGAsset.iconBMMTab,
                    selected: tabsRouter.activeIndex == 5,
                    onPressed: () {
                      tabsRouter.setActiveIndex(5);
                    },
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
