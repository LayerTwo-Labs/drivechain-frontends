import 'dart:async';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/process_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/chain_overview_card.dart';
import 'package:sidesail/widgets/containers/daemon_connection_card.dart';
import 'package:stacked/stacked.dart';

const TestchainHome = 1;
const ParentChainHome = 3;
const EthereumHome = 6;
const ZCashHome = 7;

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProcessProvider get _proccessProvider => GetIt.I.get<ProcessProvider>();

  bool _closeAlertOpen = false;

  @override
  void initState() {
    super.initState();

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await displayShutdownModal(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    // all routes must be added on-launch, and can't ever change.
    // To support multiple chains, we need to keep very good
    // track of what index is what route when setting the active
    // index, and showing the sidenav for a specific chain
    const routes = [
      // common routes
      SidechainExplorerTabRoute(),

      // testchain routes
      DashboardTabRoute(),
      TestchainRPCTabRoute(),

      TransferMainchainTabRoute(),

      WithdrawalBundleTabRoute(),
      BlindMergedMiningTabRoute(),

      // ethereum routes
      EthereumRPCTabRoute(),

      // zcash routes
      ZCashShieldTabRoute(),
      ZCashRPCTabRoute(),

      // trailing common routes
      NodeSettingsTabRoute(),
      SettingsTabRoute(),
    ];

    return auto_router.AutoTabsRouter.builder(
      homeIndex: TestchainHome,
      routes: routes,
      builder: (context, children, tabsRouter) {
        return Scaffold(
          backgroundColor: theme.colors.background,
          body: SideNav(
            child: children[tabsRouter.activeIndex],
            // assume settings tab is final tab!
            navigateToSettings: () => tabsRouter.setActiveIndex(routes.length - 2),
          ),
        );
      },
    );
  }

  Future<bool> displayShutdownModal(
    BuildContext context,
  ) async {
    if (_closeAlertOpen) return false;
    _closeAlertOpen = true;

    var processesExited = Completer<bool>();
    unawaited(_proccessProvider.shutdown().then((_) => processesExited.complete(true)));

    if (!mounted) return true;

    unawaited(
      widgetDialog(
        context: context,
        action: 'Shutdown status',
        dialogText: 'Shutting down nodes...',
        dialogType: DialogType.info,
        maxWidth: 536,
        child: SailColumn(
          spacing: SailStyleValues.padding20,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SailSpacing(SailStyleValues.padding08),
            SailRow(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _proccessProvider.runningProcesses.entries.map((entry) {
                return DaemonConnectionCard(
                  chainName: '${entry.value.name} with pid ${entry.value.pid}',
                  initializing: true,
                  connected: false,
                  errorMessage: '',
                  restartDaemon: () => entry.value.cleanup(),
                );
              }).toList(),
            ),
            const SailSpacing(SailStyleValues.padding10),
            SailRow(
              spacing: SailStyleValues.padding12,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                SailButton.primary(
                  'Force close',
                  onPressed: () {
                    processesExited.complete(true);
                    Navigator.of(context).pop(true);
                    _closeAlertOpen = false;
                  },
                  size: ButtonSize.regular,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await processesExited.future;
    return true;
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
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();

  bool collapsed = false;

  @override
  Widget build(BuildContext context) {
    final tabsRouter = auto_router.AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SideNavViewModel(navigateToSettings: widget.navigateToSettings),
      fireOnViewModelReadyOnce: true,
      onViewModelReady: (viewModel) => {
        if (!viewModel.mainchainConnected || !viewModel.sidechainConnected)
          {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.displayConnectionStatusDialog(context);
            }),
          },
      },
      builder: ((context, viewModel, child) {
        final navWidgets = navForChain(_sidechain.rpc.chain, viewModel, tabsRouter);

        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SailStyleValues.padding15,
                vertical: SailStyleValues.padding20,
              ),
              child: collapsed
                  ? SailColumn(
                      spacing: 0,
                      children: [
                        SailScaleButton(
                          onPressed: () {
                            setState(() {
                              collapsed = false;
                            });
                          },
                          child: SailSVG.icon(SailSVGAsset.iconExpand),
                        ),
                        Expanded(child: Container()),
                      ],
                    )
                  : SailColumn(
                      spacing: 0,
                      children: [
                        SailRow(
                          spacing: SailStyleValues.padding12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ChainOverviewCard(
                              chain: viewModel.chain,
                              confirmedBalance: viewModel.balance,
                              unconfirmedBalance: viewModel.pendingBalance,
                              highlighted: tabsRouter.activeIndex == 0,
                              currentChain: true,
                              onPressed: RuntimeArgs.swappableChains
                                  ? () {
                                      tabsRouter.setActiveIndex(0);
                                    }
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: SailStyleValues.padding05,
                              ),
                              child: SailScaleButton(
                                onPressed: () {
                                  setState(() {
                                    collapsed = true;
                                  });
                                },
                                child: SailSVG.icon(SailSVGAsset.iconExpand),
                              ),
                            ),
                          ],
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
                          open: true,
                          subs: [
                            SubNavEntry(
                              title: 'Node Settings',
                              selected: tabsRouter.activeIndex == tabsRouter.pageCount - 2,
                              onPressed: () {
                                tabsRouter.setActiveIndex(tabsRouter.pageCount - 2);
                              },
                            ),
                            SubNavEntry(
                              title: 'App settings',
                              selected: tabsRouter.activeIndex == tabsRouter.pageCount - 1,
                              onPressed: () {
                                tabsRouter.setActiveIndex(tabsRouter.pageCount - 1);
                              },
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        NodeConnectionStatus(
                          onChipPressed: () => viewModel.displayConnectionStatusDialog(context),
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

  List<Widget> navForChain(
    Sidechain chain,
    SideNavViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    switch (chain.type) {
      case SidechainType.testChain:
        return [
          NavEntry(
            title: '${viewModel.chain.name} Dashboard',
            icon: SailSVGAsset.iconDashboardTab,
            selected: false,
            onPressed: () {
              tabsRouter.setActiveIndex(TestchainHome);
            },
          ),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Transfer',
                selected: tabsRouter.activeIndex == TestchainHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(TestchainHome);
                },
              ),
              SubNavEntry(
                title: 'Send RPC',
                selected: tabsRouter.activeIndex == 2,
                onPressed: () {
                  tabsRouter.setActiveIndex(2);
                },
              ),
            ],
          ),
          NavEntry(
            title: 'Parent Chain Dashboard',
            icon: SailSVGAsset.iconWithdrawalBundleTab,
            selected: false,
            onPressed: () {
              tabsRouter.setActiveIndex(ParentChainHome);
            },
          ),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Transfer',
                selected: tabsRouter.activeIndex == ParentChainHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(ParentChainHome);
                },
              ),
              SubNavEntry(
                title: 'Withdrawal explorer',
                selected: tabsRouter.activeIndex == 4,
                onPressed: () {
                  tabsRouter.setActiveIndex(4);
                },
              ),
              SubNavEntry(
                title: 'Blind Merged Mining',
                selected: tabsRouter.activeIndex == 5,
                onPressed: () {
                  tabsRouter.setActiveIndex(5);
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
            selected: false,
            onPressed: () {
              tabsRouter.setActiveIndex(EthereumHome);
            },
          ),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Send RPC',
                selected: tabsRouter.activeIndex == EthereumHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(EthereumHome);
                },
              ),
            ],
          ),
          NavEntry(
            title: 'Parent Chain Dashboard',
            icon: SailSVGAsset.iconWithdrawalBundleTab,
            selected: false,
            onPressed: () {
              tabsRouter.setActiveIndex(ParentChainHome);
            },
          ),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Transfer',
                selected: tabsRouter.activeIndex == ParentChainHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(ParentChainHome);
                },
              ),
            ],
          ),
        ];

      case SidechainType.zcash:
        return [
          NavEntry(
            title: '${viewModel.chain.name} Dashboard',
            icon: SailSVGAsset.iconDashboardTab,
            selected: false,
            onPressed: () {
              tabsRouter.setActiveIndex(TestchainHome);
            },
          ),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Transfer',
                selected: tabsRouter.activeIndex == TestchainHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(TestchainHome);
                },
              ),
              SubNavEntry(
                title: 'Shield/Deshield',
                selected: tabsRouter.activeIndex == ZCashHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(ZCashHome);
                },
              ),
              SubNavEntry(
                title: 'Send RPC',
                selected: tabsRouter.activeIndex == ZCashHome + 1,
                onPressed: () {
                  tabsRouter.setActiveIndex(ZCashHome + 1);
                },
              ),
            ],
          ),
          NavEntry(
            title: 'Parent Chain Dashboard',
            icon: SailSVGAsset.iconWithdrawalBundleTab,
            selected: false,
            onPressed: () {
              tabsRouter.setActiveIndex(ParentChainHome);
            },
          ),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Transfer',
                selected: tabsRouter.activeIndex == ParentChainHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(ParentChainHome);
                },
              ),
            ],
          ),
        ];
    }
  }
}

class SideNavViewModel extends BaseViewModel {
  final VoidCallback navigateToSettings;

  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();

  bool get sidechainConnected => _sideRPC.rpc.connected;
  bool get mainchainConnected => _mainRPC.connected;

  bool get sidechainInitializing => _sideRPC.rpc.initializingBinary;
  bool get mainchainInitializing => _mainRPC.initializingBinary;

  String? get sidechainError => _sideRPC.rpc.connectionError;
  String? get mainchainError => _mainRPC.connectionError;

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Sidechain get chain => _sideRPC.rpc.chain;

  SideNavViewModel({required this.navigateToSettings}) {
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

  Future<void> displayConnectionStatusDialog(
    BuildContext context,
  ) async {
    await widgetDialog(
      context: context,
      action: 'Startup connection',
      dialogText: 'Daemon status',
      dialogType: DialogType.info,
      maxWidth: 536,
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => SideNavViewModel(navigateToSettings: navigateToSettings),
        builder: ((context, viewModel, child) {
          return SailColumn(
            spacing: SailStyleValues.padding20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SailSpacing(SailStyleValues.padding08),
              if (!_mainRPC.connected || !_sideRPC.rpc.connected)
                SailText.secondary12('You cannot use ${_sideRPC.rpc.chain.name} until nodes are connected'),
              SailRow(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DaemonConnectionCard(
                    chainName: 'Parent Chain',
                    initializing: _mainRPC.initializingBinary,
                    connected: _mainRPC.connected,
                    errorMessage: _mainRPC.connectionError,
                    restartDaemon: () => initMainchainBinary(context),
                  ),
                  DaemonConnectionCard(
                    chainName: _sideRPC.rpc.chain.name,
                    initializing: _sideRPC.rpc.initializingBinary,
                    connected: _sideRPC.rpc.connected,
                    errorMessage: _sideRPC.rpc.connectionError,
                    restartDaemon: () => initSidechainBinary(context),
                  ),
                ],
              ),
              const SailSpacing(SailStyleValues.padding10),
              SailRow(
                spacing: SailStyleValues.padding12,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SailTextButton(
                    label: 'Configure connection parameters',
                    onPressed: navigateToSettings,
                  ),
                  if (!_mainRPC.connected || !_sideRPC.rpc.connected)
                    SailButton.primary(
                      'Test connection',
                      onPressed: () {
                        _sideRPC.rpc.testConnection();
                        _mainRPC.testConnection();
                      },
                      size: ButtonSize.regular,
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> initMainchainBinary(BuildContext context) async {
    return _mainRPC.initBinary(
      context,
      _mainRPC.binary,
      bitcoinCoreBinaryArgs(_mainRPC.conf),
    );
  }

  Future<void> initSidechainBinary(
    BuildContext context,
  ) async {
    return _sideRPC.rpc.initBinary(
      context,
      _sideRPC.rpc.chain.binary,
      _sideRPC.rpc.binaryArgs(_mainRPC.conf),
    );
  }
}

class NodeConnectionStatus extends ViewModelWidget<SideNavViewModel> {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  final VoidCallback onChipPressed;

  const NodeConnectionStatus({super.key, required this.onChipPressed});

  @override
  Widget build(BuildContext context, SideNavViewModel viewModel) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (viewModel.sidechainConnected || viewModel.sidechainInitializing)
          ConnectionStatusChip(
            chain: _sidechain.rpc.chain.name,
            initializing: viewModel.sidechainInitializing,
            onPressed: onChipPressed,
          )
        else
          ConnectionErrorChip(
            chain: _sidechain.rpc.chain.name,
            onPressed: onChipPressed,
          ),
        if (viewModel.mainchainConnected || viewModel.mainchainInitializing)
          ConnectionStatusChip(
            chain: 'parent chain',
            initializing: viewModel.mainchainInitializing,
            onPressed: onChipPressed,
          )
        else
          ConnectionErrorChip(
            chain: 'parent chain',
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
      constraints: const BoxConstraints(minWidth: 187),
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
                SailText.secondary12(title, bold: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubNavEntry extends StatefulWidget {
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
  State<SubNavEntry> createState() => _SubNavEntryState();
}

class _SubNavEntryState extends State<SubNavEntry> {
  bool mouseIsOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          mouseIsOver = true;
        });
      },
      onExit: (_) {
        setState(() {
          mouseIsOver = false;
        });
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 163, maxWidth: 163),
        child: SailScaleButton(
          onPressed: widget.onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.selected ? theme.colors.actionHeader : Colors.transparent,
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
                  child: mouseIsOver || widget.selected
                      ? SailText.primary12(widget.title, bold: true)
                      : SailText.secondary12(widget.title, bold: true),
                ),
              ],
            ),
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
