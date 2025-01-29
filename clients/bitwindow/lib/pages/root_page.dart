import 'dart:async';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:sail_ui/pages/router.gr.dart' as sailroutes;
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/bottom_nav.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      animatePageTransition: false,
      routes: const [
        OverviewRoute(),
        WalletRoute(),
        SidechainsRoute(),
        LearnRoute(),
      ],
      builder: (context, child, controller) {
        final theme = SailTheme.of(context);

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
                  return Row(
                    children: [
                      QtTab(
                        icon: SailSVGAsset.iconHome,
                        label: 'Overview',
                        active: tabsRouter.activeIndex == 0,
                        onTap: () => tabsRouter.setActiveIndex(0),
                      ),
                      QtTab(
                        icon: SailSVGAsset.iconSend,
                        label: 'Send/Receive',
                        active: tabsRouter.activeIndex == 1,
                        onTap: () => tabsRouter.setActiveIndex(1),
                      ),
                      QtTab(
                        icon: SailSVGAsset.iconSidechains,
                        label: 'Sidechains',
                        active: tabsRouter.activeIndex == 2,
                        onTap: () => tabsRouter.setActiveIndex(2),
                      ),
                      QtTab(
                        icon: SailSVGAsset.iconLearn,
                        label: 'Learn',
                        active: tabsRouter.activeIndex == 3,
                        onTap: () => tabsRouter.setActiveIndex(3),
                        end: true,
                      ),
                      Expanded(child: Container()),
                      const ToggleThemeButton(),
                    ],
                  );
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
              Expanded(child: child),
              const StatusBar(),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await onShutdown(context);
    return AppExitResponse.exit;
  }

  Future<bool> onShutdown(BuildContext context) async {
    final router = GetIt.I.get<AppRouter>();
    unawaited(router.push(const sailroutes.ShuttingDownRoute()));
    final bitwindow = GetIt.I.get<BitwindowRPC>();
    final processProvider = GetIt.I.get<ProcessProvider>();

    await bitwindow.stop();
    await processProvider.shutdown();

    return true;
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    balanceProvider.addListener(setstate);
  }

  void setstate() {
    setState(() {});
  }

  String _getTimeSinceLastBlock() {
    if (blockchainProvider.lastBlockAt == null) {
      return 'Unknown';
    }

    final now = DateTime.now();
    final lastBlockTime = blockchainProvider.lastBlockAt!.toDateTime().toLocal();
    final difference = now.difference(lastBlockTime);

    if (difference.inDays > 0) {
      return '${formatTimeDifference(difference.inDays, 'day')} ago';
    } else if (difference.inHours > 0) {
      return '${formatTimeDifference(difference.inHours, 'hour')} ago';
    } else if (difference.inMinutes > 0) {
      return '${formatTimeDifference(difference.inMinutes, 'minute')} ago';
    } else {
      return '${formatTimeDifference(difference.inSeconds, 'second')} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNav(
      additionalConnection: ConnectionMonitor(
        rpc: bitwindow,
        name: 'BitWindow',
      ),
      mainchainInfo: true,
      endWidgets: [
        Tooltip(
          message: blockchainProvider.recentBlocks.firstOrNull?.toPretty() ?? '',
          child: SailText.primary12('Last block: ${_getTimeSinceLastBlock()}'),
        ),
        const DividerDot(),
        Tooltip(
          message: blockchainProvider.peers.map((e) => 'Peer id=${e.id} addr=${e.addr}').join('\n'),
          child: SailText.primary12(
            formatTimeDifference(blockchainProvider.peers.length, 'peer'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    balanceProvider.removeListener(setstate);
    super.dispose();
  }
}

String formatTimeDifference(int value, String unit) {
  return '$value $unit${value == 1 ? '' : 's'}';
}

extension on Block {
  String toPretty() {
    return 'Block $blockHeight\nBlockTime=${blockTime.toDateTime().format()}\nHash=$hash';
  }
}
