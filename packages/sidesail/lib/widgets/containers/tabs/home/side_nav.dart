import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/daemon_connection_card.dart';
import 'package:stacked/stacked.dart';

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
    final tabsRouter = AutoTabsRouter.of(context);
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
        final navWidgets = navForActivePage(_sidechain.rpc.chain, viewModel, tabsRouter);

        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: SailStyleValues.padding15,
                right: SailStyleValues.padding15,
                bottom: SailStyleValues.padding15,
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
                        const SailRow(
                          spacing: SailStyleValues.padding12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [],
                        ),
                        const SailSpacing(SailStyleValues.padding30),
                        for (final navEntry in navWidgets) navEntry,
                        Expanded(child: Container()),
                        _NodeConnectionStatus(
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

  List<Widget> _navForChain(
    Sidechain chain,
    SideNavViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    switch (chain.type) {
      case SidechainType.testChain:
        return [
          const NavCategory(category: 'Transfer'),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Send/Receive',
                selected: tabsRouter.activeIndex == TestchainHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(TestchainHome);
                },
              ),
            ],
          ),
          const NavCategory(category: 'Features'),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Send RPC',
                selected: tabsRouter.activeIndex == TestchainHome + 1,
                onPressed: () {
                  tabsRouter.setActiveIndex(TestchainHome + 1);
                },
              ),
              SubNavEntry(
                title: 'Blind Merged Mining',
                selected: tabsRouter.activeIndex == TestchainHome + 2,
                onPressed: () {
                  tabsRouter.setActiveIndex(TestchainHome + 2);
                },
              ),
            ],
          ),
        ];
      case SidechainType.ethereum:
        return [
          const NavCategory(category: 'Features'),
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
        ];

      case SidechainType.zcash:
        return [
          const NavCategory(category: 'Transfer'),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Transfer',
                selected: tabsRouter.activeIndex == ZCashHome + 2,
                onPressed: () {
                  tabsRouter.setActiveIndex(ZCashHome + 2);
                },
              ),
            ],
          ),
          const NavCategory(category: 'Features'),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Melt/Cast',
                selected: tabsRouter.activeIndex == ZCashHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(ZCashHome);
                },
              ),
              SubNavEntry(
                title: 'Shield/Deshield',
                selected: tabsRouter.activeIndex == ZCashHome + 1,
                onPressed: () {
                  tabsRouter.setActiveIndex(ZCashHome + 1);
                },
              ),
              SubNavEntry(
                title: 'Operation Statuses',
                selected: tabsRouter.activeIndex == ZCashHome + 3,
                onPressed: () {
                  tabsRouter.setActiveIndex(ZCashHome + 3);
                },
              ),
              SubNavEntry(
                title: 'Send RPC',
                selected: tabsRouter.activeIndex == ZCashHome + 4,
                onPressed: () {
                  tabsRouter.setActiveIndex(ZCashHome + 4);
                },
              ),
            ],
          ),
        ];
    }
  }

  List<Widget> navForActivePage(
    Sidechain chain,
    SideNavViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    final activeIndex = tabsRouter.activeIndex;

    switch (activeIndex) {
      case 0:
        return [];
      // parent chain home!
      case ParentChainHome || const (ParentChainHome + 1) || const (ParentChainHome + 2):
        return [
          const NavCategory(category: 'Transfer'),
          SubNavEntryContainer(
            open: true,
            subs: [
              SubNavEntry(
                title: 'Deposit/Withdraw',
                selected: tabsRouter.activeIndex == ParentChainHome,
                onPressed: () {
                  tabsRouter.setActiveIndex(ParentChainHome);
                },
              ),
              SubNavEntry(
                title: 'Transfer',
                selected: tabsRouter.activeIndex == ParentChainHome + 1,
                onPressed: () {
                  tabsRouter.setActiveIndex(ParentChainHome + 1);
                },
              ),
              if (chain.type == SidechainType.testChain)
                SubNavEntry(
                  title: 'Withdrawal explorer',
                  selected: tabsRouter.activeIndex == 4,
                  onPressed: () {
                    tabsRouter.setActiveIndex(4);
                  },
                ),
            ],
          ),
        ];
      case TestchainHome ||
            const (TestchainHome + 1) ||
            const (TestchainHome + 2) ||
            EthereumHome ||
            ZCashHome ||
            const (ZCashHome + 1) ||
            const (ZCashHome + 2) ||
            const (ZCashHome + 3) ||
            const (ZCashHome + 4):
        return _navForChain(chain, viewModel, tabsRouter);
      case SettingsHome || const (SettingsHome + 1):
        return [
          const NavCategory(category: 'Settings'),
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
        ];
      default:
        return [
          const NavCategory(category: 'Programmer error'),
        ];
    }
  }
}

class SideNavViewModel extends BaseViewModel {
  final VoidCallback navigateToSettings;

  final log = Logger(level: Level.debug);
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();

  bool get sidechainConnected => _sideRPC.rpc.connected;
  bool get mainchainConnected => _mainRPC.connected;

  bool get sidechainInitializing => _sideRPC.rpc.initializingBinary;
  bool get mainchainInitializing => _mainRPC.initializingBinary;

  int get sidechainBlockCount => _sideRPC.rpc.blockCount;
  int get mainchainBlockCount => _mainRPC.blockCount;

  String? get sidechainError => _sideRPC.rpc.connectionError;
  String? get mainchainError => _mainRPC.connectionError;

  Sidechain get chain => _sideRPC.rpc.chain;

  SideNavViewModel({required this.navigateToSettings}) {
    _sideRPC.addListener(notifyListeners);
    _mainRPC.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _sideRPC.removeListener(notifyListeners);
    _mainRPC.removeListener(notifyListeners);
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

class _NodeConnectionStatus extends ViewModelWidget<SideNavViewModel> {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  final VoidCallback onChipPressed;

  const _NodeConnectionStatus({
    required this.onChipPressed,
  });

  @override
  Widget build(BuildContext context, SideNavViewModel viewModel) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (viewModel.sidechainConnected || viewModel.sidechainInitializing)
          ConnectionStatusChip(
            chain: _sidechain.rpc.chain.name,
            initializing: viewModel.sidechainInitializing,
            blockHeight: viewModel.sidechainBlockCount,
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
            blockHeight: viewModel.mainchainBlockCount,
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
