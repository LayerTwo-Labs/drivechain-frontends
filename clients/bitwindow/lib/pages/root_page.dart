import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/providers/balance_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:bitwindow/servers/enforcer_rpc.dart';
import 'package:bitwindow/servers/mainchain_rpc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      animatePageTransition: false,
      routes: const [
        OverviewRoute(),
        SendRoute(),
        ReceiveRoute(),
        TransactionsRoute(),
        SidechainsRoute(),
      ],
      builder: (context, child, controller) {
        final theme = SailTheme.of(context);

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colors.background,
                    theme.colors.backgroundSecondary,
                  ],
                ),
              ),
              child: Builder(
                builder: (context) {
                  final tabsRouter = AutoTabsRouter.of(context);
                  return Row(
                    children: [
                      QtTab(
                        icon: Icon(
                          Icons.home,
                          color: tabsRouter.activeIndex == 0 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Overview',
                        active: tabsRouter.activeIndex == 0,
                        onTap: () => tabsRouter.setActiveIndex(0),
                      ),
                      QtTab(
                        icon: Icon(
                          Icons.send,
                          color: tabsRouter.activeIndex == 1 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Send',
                        active: tabsRouter.activeIndex == 1,
                        onTap: () => tabsRouter.setActiveIndex(1),
                      ),
                      QtTab(
                        icon: Icon(
                          Icons.qr_code,
                          color: tabsRouter.activeIndex == 2 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Receive',
                        active: tabsRouter.activeIndex == 2,
                        onTap: () => tabsRouter.setActiveIndex(2),
                      ),
                      QtTab(
                        icon: Icon(
                          Icons.list,
                          color: tabsRouter.activeIndex == 3 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Transactions',
                        active: tabsRouter.activeIndex == 3,
                        onTap: () => tabsRouter.setActiveIndex(3),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: DottedBorder(
                          strokeWidth: 0.5,
                          // only left and right border
                          customPath: (size) => Path()
                            ..moveTo(0, 0)
                            ..lineTo(0, size.height)
                            ..moveTo(size.width, size.height)
                            ..lineTo(size.width, 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: QtTab(
                              icon: Icon(
                                Icons.link,
                                color: tabsRouter.activeIndex == 4 ? theme.colors.primary : theme.colors.text,
                              ),
                              label: 'Sidechains',
                              active: tabsRouter.activeIndex == 4,
                              onTap: () => tabsRouter.setActiveIndex(4),
                            ),
                          ),
                        ),
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
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
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
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BottomNavViewModel(),
      fireOnViewModelReadyOnce: true,
      onViewModelReady: (model) {
        if (!model.mainchainConnected || !model.enforcerConnected || !model.serverConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            displayConnectionStatusDialog(context);
          });
        }
      },
      builder: ((context, model, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Tooltip(
                    message: 'Confirmed balance',
                    child: SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailSVG.icon(SailSVGAsset.iconSuccess),
                        SailText.secondary12(formatBitcoin(balanceProvider.balance, symbol: 'BTC')),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Unconfirmed balance',
                    child: SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailSVG.icon(SailSVGAsset.iconPending),
                        SailText.secondary12(formatBitcoin(balanceProvider.pendingBalance, symbol: 'BTC')),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(child: Container()),
              SailText.primary12(
                '${formatWithThousandSpacers(blockchainProvider.blockchainInfo.blocks)} blocks',
              ),
              Tooltip(
                message: blockchainProvider.peers.map((e) => 'Peer id=${e.id} addr=${e.addr}').join('\n'),
                child: SailText.primary12(
                  formatTimeDifference(blockchainProvider.peers.length, 'peer'),
                ),
              ),
              Tooltip(
                message: blockchainProvider.recentBlocks.firstOrNull?.toPretty() ?? '',
                child: SailText.primary12('Last block: ${_getTimeSinceLastBlock()}'),
              ),
            ]
                .map(
                  (child) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 2.0,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: child,
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }

  Future<void> displayConnectionStatusDialog(
    BuildContext context,
  ) async {
    await widgetDialog(
      context: context,
      action: 'Startup connection',
      dialogText: 'Daemon status',
      dialogType: DialogType.info,
      maxWidth: 566,
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => BottomNavViewModel(),
        builder: ((context, model, child) {
          return SailColumn(
            spacing: SailStyleValues.padding20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SailSpacing(SailStyleValues.padding08),
              if (!model.mainchainConnected || !model.enforcerConnected || !model.serverConnected)
                SailText.secondary12('You cannot use BitWindow until backends are connected'),
              SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DaemonConnectionCard(
                    connection: model.mainchain,
                    restartDaemon: () => model.initMainchainBinary(context),
                    infoMessage: null,
                    navigateToLogs: model.navigateToLogs,
                  ),
                  DaemonConnectionCard(
                    connection: model.enforcer,
                    infoMessage: model.inIBD ? 'Waiting for L1 initial block download to complete...' : null,
                    restartDaemon: () => model.initEnforcerBinary(context),
                    navigateToLogs: model.navigateToLogs,
                  ),
                  DaemonConnectionCard(
                    connection: model.server,
                    infoMessage: model.inIBD ? 'Waiting for enforcer to start' : null,
                    restartDaemon: () => model.initServerBinary(context),
                    navigateToLogs: model.navigateToLogs,
                  ),
                ],
              ),
            ],
          );
        }),
      ),
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

extension on ListRecentBlocksResponse_RecentBlock {
  String toPretty() {
    return 'Block $blockHeight\nBlockTime=${blockTime.toDateTime().format()}\nHash=$hash';
  }
}

class BottomNavViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  AppRouter get router => GetIt.I.get<AppRouter>();

  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  API get server => GetIt.I.get<API>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  int get balance => _balanceProvider.balance;
  int get pendingBalance => _balanceProvider.pendingBalance;

  bool get mainchainConnected => mainchain.connected;
  bool get enforcerConnected => enforcer.connected;
  bool get serverConnected => server.connected;

  bool get mainchainInitializing => mainchain.initializingBinary;
  bool get enforcerInitializing => enforcer.initializingBinary;
  bool get serverInitializing => server.initializingBinary;
  bool get inIBD => mainchain.inIBD;

  int get blockCount => mainchain.blockCount;

  String? get mainchainError => mainchain.connectionError;
  String? get enforcerError => enforcer.connectionError;
  String? get serverError => server.connectionError;

  BottomNavViewModel() {
    mainchain.addListener(notifyListeners);
    enforcer.addListener(notifyListeners);
    server.addListener(notifyListeners);
  }

  Future<void> initMainchainBinary(BuildContext context) async {
    return mainchain.initBinary(
      context,
      ParentChain().binary,
    );
  }

  Future<void> initEnforcerBinary(
    BuildContext context,
  ) async {
    final binary = 'bip300301-enforcer';
    await enforcer.initBinary(context, binary);
  }

  Future<void> initServerBinary(
    BuildContext context,
  ) async {
    final binary = 'drivechain-server';
    await server.initBinary(context, binary);
  }

  void navigateToLogs(String name, String logPath) {
    router.push(
      SailLogRoute(
        name: name,
        logPath: logPath,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    mainchain.removeListener(notifyListeners);
    enforcer.removeListener(notifyListeners);
    server.removeListener(notifyListeners);
  }
}
