import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/bottom_nav.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';
import 'package:sail_ui/widgets/platform_menu.dart';
import 'package:sidesail/main.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:stacked/stacked.dart';
import 'package:window_manager/window_manager.dart';

// IMPORTANT: Update router.dart AND routes in HomePage further down
// in this file, when updating here. Route order should match exactly
enum Tabs {
  // parent chain routes
  ParentChainPeg,
  ParentChainBMM,

  // sidechain balance/transfer route
  SidechainOverview,

  // zcash routes
  ZCashShieldDeshield,
  ZCashMeltCast,

  // trailing common routes
  SettingsHome,
}

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver, WindowListener {
  NotificationProvider get _notificationProvider => GetIt.I.get<NotificationProvider>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();

  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationProvider.addListener(rebuildNotifications);
    _initializeWindowManager();
  }

  Future<void> _initializeWindowManager() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  void rebuildNotifications() {
    notificationsNotifier.value = _notificationProvider.notifications;

    // call notifyListeners manually coz == on List<Widget> doesn't work..
    // ignore: invalid_use_of_protected_member,invalid_use_of_visible_for_testing_member
    notificationsNotifier.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    // all routes must be added on-launch, and can't ever change.
    // To support multiple chains, we need to keep very good
    // track of what index is what route when setting the active
    // index, and showing the sidenav for a specific chain
    // IMPORTANT: Must matche exactly the order in router.dart
    const routes = [
      // parent chain routes
      DepositWithdrawTabRoute(),
      BlindMergedMiningTabRoute(),

      // sidechain balance/transfer route
      SidechainOverviewTabRoute(),

      // zcash routes
      ZCashShieldDeshieldTabRoute(),
      ZCashMeltCastTabRoute(),

      // trailing common routes
      SettingsTabRoute(),
    ];

    return CrossPlatformMenuBar(
      menus: [
        PlatformMenu(
          label: sidechain.rpc.chain.name,
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'About $sidechain.rpc.chain.name',
                  onSelected: null,
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Quit $sidechain.rpc.chain.name',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
                  onSelected: () => didRequestAppExit(),
                ),
              ],
            ),
          ],
        ),

        // This Node menu
        PlatformMenu(
          label: 'This Node',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Console',
                  onSelected: () async {
                    final applicationDir = await getApplicationSupportDirectory();
                    final logFile = await getLogFile();

                    final window = await DesktopMultiWindow.createWindow(
                      jsonEncode({
                        'window_type': 'console',
                        'application_dir': applicationDir.path,
                        'log_file': logFile.path,
                      }),
                    );
                    await window.setFrame(const Offset(0, 0) & const Size(1280, 720));
                    await window.center();
                    await window.setTitle('$sidechain.rpc.chain.name Console');
                    await window.show();
                  },
                ),
                PlatformMenuItem(
                  label: 'View Logs',
                  onSelected: () => GetIt.I.get<AppRouter>().push(
                        LogRoute(
                          title: '$sidechain.rpc.chain.name Logs',
                          logPath: sidechain.rpc.logPath,
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.colors.background,
        body: auto_router.AutoTabsRouter.builder(
          homeIndex: Tabs.ParentChainPeg.index,
          routes: routes,
          builder: (context, children, tabsRouter) {
            return ViewModelBuilder.reactive(
              viewModelBuilder: () => HomePageViewModel(),
              fireOnViewModelReadyOnce: true,
              builder: (context, model, child) {
                final sidechainNav = _navForSidechain(sidechain.rpc.chain, model, tabsRouter);

                return Scaffold(
                  backgroundColor: theme.colors.background,
                  appBar: TopNav(
                    routes: [
                      TopNavRoute(
                        label: 'Parent Chain',
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index);
                        },
                      ),
                      ...sidechainNav,
                    ],
                  ),
                  body: Column(
                    children: [
                      Expanded(child: children[tabsRouter.activeIndex]),
                      BottomNav(
                        mainchainInfo: false,
                        additionalConnection: ConnectionMonitor(
                          rpc: sidechain.rpc,
                          name: sidechain.rpc.chain.name,
                        ),
                        navigateToLogs: (title, logPath) {
                          GetIt.I.get<AppRouter>().push(
                                LogRoute(
                                  title: title,
                                  logPath: logPath,
                                ),
                              );
                        },
                        endWidgets: [
                          SailButton(
                            icon: SailSVGAsset.settings,
                            variant: ButtonVariant.icon,
                            onPressed: () async => tabsRouter.setActiveIndex(Tabs.SettingsHome.index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<TopNavRoute> _navForSidechain(
    Sidechain chain,
    HomePageViewModel viewModel,
    auto_router.TabsRouter tabsRouter,
  ) {
    // Base navigation items that all sidechains have
    var baseNav = [
      TopNavRoute(
        label: 'Overview',
        optionalKey: Tabs.SidechainOverview.index,
        onTap: () {
          tabsRouter.setActiveIndex(Tabs.SidechainOverview.index);
        },
      ),
    ];

    switch (chain) {
      case TestSidechain():
        return baseNav;
      case ZCash():
        return [
          ...baseNav,
          TopNavRoute(
            label: 'Shield/Deshield',
            optionalKey: Tabs.ZCashShieldDeshield.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashShieldDeshield.index);
            },
          ),
          TopNavRoute(
            label: 'Melt/Cast',
            optionalKey: Tabs.ZCashMeltCast.index,
            onTap: () {
              tabsRouter.setActiveIndex(Tabs.ZCashMeltCast.index);
            },
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

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await onShutdown(onComplete: () {});
    return AppExitResponse.exit;
  }

  Future<bool> onShutdown({required VoidCallback onComplete}) async {
    try {
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      final processProvider = GetIt.I.get<ProcessProvider>();

      // Get list of running binaries
      final runningBinaries = processProvider.runningProcesses.values.map((process) => process.binary).toList();

      // Show shutdown page with running binaries
      unawaited(
        GetIt.I.get<AppRouter>().push(
              ShuttingDownRoute(
                binaries: runningBinaries,
                onComplete: onComplete,
              ),
            ),
      );

      final futures = <Future>[];

      // Only stop binaries that are started by sidesail!
      // For example if the user starts bitcoind manually, we shouldn't kill it
      for (final binary in runningBinaries) {
        futures.add(binaryProvider.stop(binary));
      }

      // Wait for all stop operations to complete
      await Future.wait(futures);

      // after all binaries are asked nicely to stop, kill any lingering processes
      await processProvider.shutdown();
    } catch (error) {
      // do nothing, we just always need to return true
    }

    return true;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await onShutdown(
        onComplete: () async {
          if (isPreventClose) {
            await windowManager.destroy();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Binary get chain => _sideRPC.rpc.chain;

  HomePageViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
