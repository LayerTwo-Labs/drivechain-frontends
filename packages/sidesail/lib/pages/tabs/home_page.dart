import 'dart:async';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sidesail/providers/process_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/widgets/containers/daemon_connection_card.dart';
import 'package:sidesail/widgets/containers/tabs/home/side_nav.dart';
import 'package:sidesail/widgets/containers/tabs/home/top_nav.dart';

const ParentChainHome = 1;
const TestchainHome = 3;
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

      // parent chain routes
      TransferMainchainTabRoute(),
      WithdrawalBundleTabRoute(),

      // testchain routes
      DashboardTabRoute(),
      TestchainRPCTabRoute(),
      BlindMergedMiningTabRoute(),

      // ethereum routes
      EthereumRPCTabRoute(),

      // zcash routes
      ZCashMeltCastTabRoute(),
      ZCashShieldDeshieldTabRoute(),
      ZCashRPCTabRoute(),
      ZCashTransferTabRoute(),

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
          body: TopNav(
            child: SideNav(
              child: children[tabsRouter.activeIndex],
              // assume settings tab is second to last tab!
              navigateToSettings: () => tabsRouter.setActiveIndex(routes.length - 2),
            ),
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
                  chainName: entry.value.name,
                  initializing: true,
                  connected: false,
                  errorMessage: 'with pid ${entry.value.pid}',
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
