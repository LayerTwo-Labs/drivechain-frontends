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
        final trailingSidechainNav = _navForSidechainTrailing(_sidechain.rpc.chain, model, widget.tabsRouter);

        return SailRow(
          spacing: 0,
          children: [
            Row(
              children: [
                QtTab(
                  label: 'Deposit/Withdraw',
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
            ...trailingSidechainNav,
            Expanded(child: Container()),
            const ToggleThemeButton(),
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
    switch (chain) {
      case TestSidechain():
        return [
          QtTab(
            label: 'Send',
            active: tabsRouter.activeIndex == Tabs.SidechainSend.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.SidechainSend.index);
            },
            icon: SailSVGAsset.iconTabSidechainSend,
          ),
        ];
      case EthereumSidechain():
        return [
          QtTab(
            label: 'Console',
            active: tabsRouter.activeIndex == Tabs.EthereumConsole.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.EthereumConsole.index);
            },
            icon: SailSVGAsset.iconTabConsole,
          ),
        ];

      case ZCash():
        return [
          QtTab(
            label: 'Send',
            active: tabsRouter.activeIndex == Tabs.ZCashTransfer.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashTransfer.index);
            },
            icon: SailSVGAsset.iconTabSidechainSend,
          ),
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
          QtTab(
            label: 'Operation Statuses',
            active: tabsRouter.activeIndex == Tabs.ZCashOperationStatuses.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashOperationStatuses.index);
            },
            icon: SailSVGAsset.iconTabZCashOperationStatuses,
          ),
        ];

      case ParentChain():
        return [];
      case Thunder():
        return [];
      case Bitnames():
        return [];
      default:
        throw Exception('could not handle unknown sidechain type ${chain.runtimeType}');
    }
  }

  List<QtTab> _navForSidechainTrailing(
    Binary chain,
    TopNavViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    List<QtTab> trailing = [];

    switch (chain) {
      case TestSidechain():
        trailing = [
          QtTab(
            label: 'Console',
            active: tabsRouter.activeIndex == Tabs.TestchainConsole.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.TestchainConsole.index);
            },
            icon: SailSVGAsset.iconTabConsole,
          ),
        ];
        break;

      case EthereumSidechain():
        break;

      case ZCash():
        trailing = [
          QtTab(
            label: 'Console',
            active: tabsRouter.activeIndex == Tabs.ZCashConsole.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashConsole.index);
            },
            icon: SailSVGAsset.iconTabConsole,
          ),
        ];
        break;

      case ParentChain():
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
        icon: SailSVGAsset.iconTabSettings,
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
