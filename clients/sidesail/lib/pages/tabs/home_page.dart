import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/pages/router.gr.dart' as sailroutes;
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/bottom_nav.dart';
import 'package:sail_ui/widgets/platform_menu.dart';
import 'package:sidesail/main.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/widgets/containers/tabs/home/top_nav.dart';

// IMPORTANT: Update router.dart AND routes in HomePage further down
// in this file, when updating here. Route order should match exactly
enum Tabs {
  // common routes
  SidechainExplorer,

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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  NotificationProvider get _notificationProvider => GetIt.I.get<NotificationProvider>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();

  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _notificationProvider.addListener(rebuildNotifications);
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
      // common routes
      SidechainExplorerTabRoute(),

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
        // First menu will be Apple menu (system provided)
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
            return Scaffold(
              backgroundColor: theme.colors.background,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                  ),
                  child: Builder(
                    builder: (context) {
                      final tabsRouter = AutoTabsRouter.of(context);
                      return TopNav(tabsRouter: tabsRouter);
                    },
                  ),
                ),
              ),
              body: Column(
                children: [
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey,
                  ),
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
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => tabsRouter.setActiveIndex(Tabs.SettingsHome.index),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await onShutdown(context);
    return AppExitResponse.exit;
  }

  Future<bool> onShutdown(BuildContext context) async {
    final router = GetIt.I.get<AppRouter>();
    unawaited(router.push(const sailroutes.ShuttingDownRoute()));
    final sidechain = GetIt.I.get<SidechainContainer>();
    final processProvider = GetIt.I.get<ProcessProvider>();

    await sidechain.rpc.stop();
    await processProvider.shutdown();

    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
