import 'dart:async';
import 'dart:ui';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thunder/main.dart';
import 'package:thunder/routing/router.dart';
import 'package:window_manager/window_manager.dart';

// IMPORTANT: Update router.dart AND routes in HomePage further down
// in this file, when updating here. Route order should match exactly
enum Tabs {
  // parent chain routes
  ParentChainPeg,

  // sidechain balance/transfer route
  SidechainOverview,

  // sidechain balance/transfer route
  Console,

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
  ThunderRPC get thunderRPC => GetIt.I.get<ThunderRPC>();

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

    return CrossPlatformMenuBar(
      menus: [
        PlatformMenu(
          label: thunderRPC.chain.name,
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'About $thunderRPC.rpc.chain.name',
                  onSelected: null,
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Quit $thunderRPC.rpc.chain.name',
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
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    await windowProvider.open(SubWindowTypes.console);
                  },
                ),
                PlatformMenuItem(
                  label: 'View Logs',
                  onSelected: () {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    windowProvider.open(SubWindowTypes.logs);
                  },
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
          routes: [
            // parent chain routes
            ParentChainRoute(),
            // sidechain balance/transfer route
            SidechainOverviewTabRoute(),
            // sidechain console route
            ConsoleTabRoute(),
            // trailing common routes
            SettingsTabRoute(),
          ],
          builder: (context, children, tabsRouter) {
            return ViewModelBuilder.reactive(
              viewModelBuilder: () => HomePageViewModel(),
              fireOnViewModelReadyOnce: true,
              builder: (context, model, child) {
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
                      TopNavRoute(
                        label: 'Overview',
                        optionalKey: Tabs.SidechainOverview.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.SidechainOverview.index);
                        },
                      ),
                      TopNavRoute(
                        label: 'Console',
                        optionalKey: Tabs.Console.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.Console.index);
                        },
                      ),
                      TopNavRoute(
                        icon: SailSVGAsset.settings,
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      Expanded(child: children[tabsRouter.activeIndex]),
                      BottomNav(
                        mainchainInfo: false,
                        additionalConnection: ConnectionMonitor(
                          rpc: thunderRPC,
                          name: thunderRPC.chain.name,
                        ),
                        navigateToLogs: (title, logPath) {
                          GetIt.I.get<AppRouter>().push(
                                LogRoute(
                                  title: title,
                                  logPath: logPath,
                                ),
                              );
                        },
                        endWidgets: [],
                        onlyShowAdditional: true,
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

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await GetIt.I.get<BinaryProvider>().onShutdown(
          shutdownOptions: ShutdownOptions(
            router: GetIt.I.get<AppRouter>(),
            onComplete: () {},
          ),
        );
    return AppExitResponse.exit;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await GetIt.I.get<BinaryProvider>().onShutdown(
            shutdownOptions: ShutdownOptions(
              router: GetIt.I.get<AppRouter>(),
              onComplete: () async {
                if (isPreventClose) {
                  await windowManager.destroy();
                }
              },
            ),
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
  ThunderRPC get _rpc => GetIt.I.get<ThunderRPC>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Binary get chain => _rpc.chain;

  HomePageViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
