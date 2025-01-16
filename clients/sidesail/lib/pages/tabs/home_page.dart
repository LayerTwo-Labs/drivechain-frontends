import 'dart:async';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/widgets/containers/tabs/home/bottom_nav.dart';
import 'package:sidesail/widgets/containers/tabs/home/top_nav.dart';

// IMPORTANT: Update router.dart AND routes in HomePage further down
// in this file, when updating here. Route order should match exactly
enum Tabs {
  SidechainExplorer,

  ParentChainPeg,
  ParentChainWithdrawalExplorer,
  ParentChainBMM,

  SidechainSend,
  TestchainConsole,

  EthereumConsole,

  ZCashMeltCast,
  ZCashShieldDeshield,
  ZCashTransfer,
  ZCashOperationStatuses,
  ZCashConsole,

  SettingsHome,
}

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationProvider get _notificationProvider => GetIt.I.get<NotificationProvider>();
  ProcessProvider get _proccessProvider => GetIt.I.get<ProcessProvider>();

  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);

  bool _closeAlertOpen = false;

  @override
  void initState() {
    super.initState();

    _notificationProvider.addListener(rebuildNotifications);
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await displayShutdownModal(context);
    });
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
      WithdrawalExplorerTabRoute(),
      BlindMergedMiningTabRoute(),

      // testchain routes
      SidechainSendRoute(),
      TestchainRPCTabRoute(),

      // ethereum routes
      EthereumRPCTabRoute(),

      // zcash routes
      ZCashMeltCastTabRoute(),
      ZCashShieldDeshieldTabRoute(),
      ZCashTransferTabRoute(),
      ZCashOperationStatusesTabRoute(),
      ZCashRPCTabRoute(),

      // trailing common routes
      SettingsTabRoute(),
    ];

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: auto_router.AutoTabsRouter.builder(
        homeIndex: Tabs.ParentChainPeg.index,
        routes: routes,
        builder: (context, children, tabsRouter) {
          return Scaffold(
            backgroundColor: theme.colors.background,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
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
                BottomNav(navigateToSettings: () => tabsRouter.setActiveIndex(Tabs.SettingsHome.index)),
              ],
            ),
          );
        },
      ),
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
        title: 'Shutdown status',
        subtitle: 'Shutting down nodes...',
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
                return ShutdownCard(
                  chain: Binary.fromBinary(entry.value.binary)!,
                  initializing: true,
                  message: 'with pid ${entry.value.pid}',
                  forceCleanup: () => entry.value.cleanup(),
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

class ShutdownCard extends StatelessWidget {
  final Binary chain;
  final String message;
  final bool initializing;
  final VoidCallback forceCleanup;

  const ShutdownCard({
    super.key,
    required this.chain,
    required this.initializing,
    required this.message,
    required this.forceCleanup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SizedBox(
      width: 250,
      child: SailBorder(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding12,
          vertical: SailStyleValues.padding08,
        ),
        child: SailColumn(
          spacing: 0,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.fromAsset(SailSVGAsset.iconGlobe, color: theme.colors.orangeLight),
                SailText.primary13('${chain.name} daemon'),
                Expanded(child: Container()),
                SailScaleButton(
                  onPressed: forceCleanup,
                  child: InitializingDaemonSVG(
                    animate: initializing,
                  ),
                ),
              ],
            ),
            const SailSpacing(SailStyleValues.padding12),
            SailText.secondary12(
              message,
            ),
          ],
        ),
      ),
    );
  }
}
