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
import 'package:window_manager/window_manager.dart';
import 'package:zside/main.dart';
import 'package:zside/routing/router.dart';

// IMPORTANT: Update router.dart AND routes in HomePage further down
// in this file, when updating here. Route order should match exactly
enum Tabs {
  // parent chain routes
  ParentChainPeg,

  // zside homepage
  ZSideHomepage,

  // zside routes
  ZSideShieldDeshield,
  ZSideMeltCast,

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
  ZSideRPC get _rpc => GetIt.I.get<ZSideRPC>();

  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);
  bool _shutdownInProgress = false;

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
          label: _rpc.chain.name,
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'About $ZSideRPC.rpc.chain.name',
                  onSelected: null,
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Quit $ZSideRPC.rpc.chain.name',
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
          homeIndex: Tabs.ZSideHomepage.index,
          routes: [
            // parent chain routes
            ParentChainRoute(),

            // zside homepage
            ZSideHomepageRoute(),

            // zside routes
            ZSideShieldDeshieldTabRoute(),
            ZSideMeltCastTabRoute(),

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
                        label: 'Home',
                        optionalKey: Tabs.ZSideHomepage.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.ZSideHomepage.index);
                        },
                      ),
                      TopNavRoute(
                        label: 'Shield/Deshield',
                        optionalKey: Tabs.ZSideShieldDeshield.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.ZSideShieldDeshield.index);
                        },
                      ),
                      TopNavRoute(
                        label: 'Melt/Cast',
                        optionalKey: Tabs.ZSideMeltCast.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.ZSideMeltCast.index);
                        },
                      ),
                    ],
                    endWidget: SailButton(
                      label: 'Configure Homepage',
                      small: true,
                      onPressed: () async {
                        await GetIt.I.get<AppRouter>().push(ZSideConfigureHomepageRoute());
                      },
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(child: children[tabsRouter.activeIndex]),
                      BottomNav(
                        mainchainInfo: false,
                        onlyShowAdditional: true,
                        additionalConnection: ConnectionMonitor(
                          rpc: _rpc,
                          name: _rpc.chain.name,
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

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    // If shutdown is already in progress, trigger force-kill
    if (_shutdownInProgress) {
      await GetIt.I.get<BinaryProvider>().onShutdown(
        shutdownOptions: ShutdownOptions(
          router: GetIt.I.get<AppRouter>(),
          onComplete: () async {},
          showShutdownPage: false,
          forceKill: true,
        ),
      );
      return AppExitResponse.exit;
    }

    _shutdownInProgress = true;
    await GetIt.I.get<BinaryProvider>().onShutdown();
    return AppExitResponse.exit;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // If shutdown is already in progress, trigger force-kill
      if (_shutdownInProgress) {
        await GetIt.I.get<BinaryProvider>().onShutdown(
          shutdownOptions: ShutdownOptions(
            router: GetIt.I.get<AppRouter>(),
            onComplete: () async {
              if (isPreventClose) {
                await windowManager.destroy();
              }
            },
            showShutdownPage: false,
            forceKill: true,
          ),
        );
        return;
      }

      _shutdownInProgress = true;
      await GetIt.I.get<BinaryProvider>().onShutdown(
        shutdownOptions: ShutdownOptions(
          router: GetIt.I.get<AppRouter>(),
          onComplete: () async {
            if (isPreventClose) {
              await windowManager.destroy();
            }
          },
          showShutdownPage: true,
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
  ZSideRPC get _rpc => GetIt.I.get<ZSideRPC>();

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
