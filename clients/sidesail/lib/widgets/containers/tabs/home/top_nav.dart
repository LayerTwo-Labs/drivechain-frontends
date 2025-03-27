import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:stacked/stacked.dart';

class TopNav extends StatefulWidget {
  final auto_router.TabsRouter tabsRouter;

  const TopNav({
    super.key,
    required this.tabsRouter,
  });

  @override
  State<TopNav> createState() => _TopNavState();
}

class _TopNavState extends State<TopNav> {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TopNavViewModel(),
      fireOnViewModelReadyOnce: true,
      builder: ((context, model, child) {
        final sidechainNav = _navForSidechain(_sidechain.rpc.chain, model, widget.tabsRouter);

        return SailRow(
          spacing: 0,
          children: [
            Row(
              children: [
                QtTab(
                  label: 'Parent Chain',
                  active: widget.tabsRouter.activeIndex == Tabs.ParentChainPeg.index,
                  onTap: () {
                    widget.tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index);
                  },
                  icon: SailSVGAsset.iconTabPeg,
                ),
                if (_sidechain.rpc.chain == TestSidechain())
                  QtTab(
                    label: 'Blind Merged Mining',
                    active: widget.tabsRouter.activeIndex == Tabs.ParentChainBMM.index,
                    onTap: () {
                      widget.tabsRouter.setActiveIndex(Tabs.ParentChainBMM.index);
                    },
                    icon: SailSVGAsset.iconTabBMM,
                  ),
              ],
            ),
            SizedBox(
              height: 50,
              child: VerticalDivider(
                width: 1,
                thickness: 1,
                color: theme.colors.icon.withValues(alpha: 0.2),
              ),
            ),
            ...sidechainNav,
            Expanded(child: Container()),
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
    // Base navigation items that all sidechains have
    var baseNav = [
      QtTab(
        label: 'Overview',
        active: tabsRouter.activeIndex == Tabs.SidechainOverview.index,
        onTap: () {
          tabsRouter.setActiveIndex(Tabs.SidechainOverview.index);
        },
        icon: SailSVGAsset.iconTabTools,
      ),
    ];

    switch (chain) {
      case TestSidechain():
        return baseNav;
      case ZCash():
        return [
          ...baseNav,
          QtTab(
            label: 'Shield/Deshield',
            active: tabsRouter.activeIndex == Tabs.ZCashShieldDeshield.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashShieldDeshield.index);
            },
            icon: SailSVGAsset.iconTabZCashShieldDeshield,
          ),
          QtTab(
            label: 'Melt/Cast',
            active: tabsRouter.activeIndex == Tabs.ZCashMeltCast.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashMeltCast.index);
            },
            icon: SailSVGAsset.iconTabZCashMeltCast,
          ),
        ];

      case ParentChain():
        return baseNav;
      case Thunder():
        return baseNav;
      case Bitnames():
        return baseNav;
      default:
        throw Exception('could not handle unknown sidechain type ${chain.runtimeType}');
    }
  }
}

class TopNavViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Binary get chain => _sideRPC.rpc.chain;

  TopNavViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
