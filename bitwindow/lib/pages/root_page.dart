import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/merchants/chain_merchants_dialog.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/wallet/bitcoin_uri_dialog.dart';
import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver, WindowListener {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final _routerKey = GlobalKey<AutoTabsRouterState>();
  final _clientSettings = GetIt.I<ClientSettings>();

  List<Topic> get topics => _newsProvider.topics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWindowManager();
  }

  Future<void> _initializeWindowManager() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  @override
  Widget build(BuildContext context) {
    final app = SailApp.of(context);

    return CrossPlatformMenuBar(
      menus: [
        // First menu will be Apple menu (system provided)
        PlatformMenu(
          label: 'bitwindow',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'About bitwindow',
                  onSelected: null,
                ),
                PlatformMenuItem(
                  label: 'Change Theme',
                  onSelected: () async {
                    final log = GetIt.I.get<Logger>();

                    final themeSetting = await _clientSettings.getValue(ThemeSetting());
                    final currentTheme = themeSetting.value;

                    final SailThemeValues nextTheme = currentTheme.toggleTheme();

                    await _clientSettings.setValue(ThemeSetting().withValue(nextTheme));
                    await app.loadTheme(nextTheme);
                    log.d('Theme change complete from ${currentTheme.name} to ${nextTheme.name}');
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Hide bitwindow',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyH, meta: true),
                  onSelected: () async {
                    await windowManager.hide();
                  },
                ),
                PlatformMenuItem(
                  label: 'Show All',
                  onSelected: () async {
                    await windowManager.show();
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Quit bitwindow',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
                  onSelected: () => GetIt.I.get<BinaryProvider>().onShutdown(
                        shutdownOptions: ShutdownOptions(
                          router: GetIt.I.get<AppRouter>(),
                          onComplete: () => exit(0),
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),

        // Now our actual menus start
        PlatformMenu(
          label: 'Your Wallet',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Address Book',
                  onSelected: () {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    windowProvider.open(SubWindowTypes.addressbook);
                  },
                ),
              ],
            ),
          ],
        ),

        // Banking menu (first custom menu)
        PlatformMenu(
          label: 'Banking',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Send Money',
                  onSelected: () {
                    final tabsRouter = _routerKey.currentState?.controller;
                    tabsRouter?.setActiveIndex(1);

                    if (WalletPage.tabKey.currentState != null) {
                      WalletPage.tabKey.currentState!.setIndex(1, null);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'Request Money',
                  onSelected: () {
                    final tabsRouter = _routerKey.currentState?.controller;
                    tabsRouter?.setActiveIndex(1);
                    if (WalletPage.tabKey.currentState != null) {
                      WalletPage.tabKey.currentState!.setIndex(2, null);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'See Wallet Transactions',
                  onSelected: () {
                    final tabsRouter = _routerKey.currentState?.controller;
                    tabsRouter?.setActiveIndex(1);
                    if (WalletPage.tabKey.currentState != null) {
                      WalletPage.tabKey.currentState!.setIndex(0, null);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'Open URI Link',
                  onSelected: () async {
                    final result = await showDialog<BitcoinURI>(
                      context: context,
                      builder: (context) => const BitcoinURIDialog(),
                    );
                    if (result != null) {
                      final tabsRouter = _routerKey.currentState?.controller;
                      tabsRouter?.setActiveIndex(1);

                      if (WalletPage.tabKey.currentState != null) {
                        WalletPage.tabKey.currentState!.setIndex(1, null);
                      }

                      // Handle the URI in the wallet page
                      WalletPage.handleBitcoinURI(result);
                    }
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Deniability',
                  onSelected: () async {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    await windowProvider.open(SubWindowTypes.deniability);
                  },
                ),
              ],
            ),
          ],
        ),

        // Use Bitcoin menu
        PlatformMenu(
          label: 'Use Bitcoin',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Broadcast CoinNews',
                  onSelected: () => displayBroadcastNewsDialog(context),
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Sign / Verify Message',
                  onSelected: () {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    windowProvider.open(SubWindowTypes.messageSigner);
                  },
                ),
                PlatformMenuItem(
                  label: 'Chain Merchants',
                  onSelected: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ChainMerchantsDialog(),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Sidechains',
                  onSelected: () {
                    final tabsRouter = _routerKey.currentState?.controller;
                    tabsRouter?.setActiveIndex(2);
                  },
                ),
              ],
            ),
          ],
        ),

        // Crypto Tools menu
        PlatformMenu(
          label: 'Crypto Tools',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Block Explorer',
                  onSelected: () async {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    await windowProvider.open(SubWindowTypes.blockExplorer);
                  },
                ),
                PlatformMenuItem(
                  label: 'Hash Calculator',
                  onSelected: () {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    windowProvider.open(SubWindowTypes.hashCalculator);
                  },
                ),
                PlatformMenuItem(
                  label: 'Merkle Tree',
                  onSelected: null,
                ),
                PlatformMenuItem(
                  label: 'Signatures',
                  onSelected: null,
                ),
                PlatformMenuItem(
                  label: 'Base58Check Decoder',
                  onSelected: null,
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
                  label: 'Debug Window',
                  onSelected: () async {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    await windowProvider.open(SubWindowTypes.debug);
                  },
                ),
                PlatformMenuItem(
                  label: 'View Logs',
                  onSelected: () async {
                    final windowProvider = GetIt.I.get<WindowProvider>();
                    await windowProvider.open(SubWindowTypes.logs);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      child: AutoTabsRouter.tabBar(
        key: _routerKey,
        animatePageTransition: false,
        routes: const [
          OverviewRoute(),
          WalletRoute(),
          SidechainsRoute(),
          LearnRoute(),
          SettingsRoute(),
        ],
        builder: (context, child, controller) {
          final theme = SailTheme.of(context);

          return SelectionArea(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: theme.colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Scaffold(
                backgroundColor: theme.colors.background,
                appBar: TopNav(
                  routes: [
                    TopNavRoute(
                      label: 'Overview',
                    ),
                    TopNavRoute(
                      label: 'Wallet',
                    ),
                    TopNavRoute(
                      label: 'Sidechains',
                    ),
                    TopNavRoute(
                      label: 'Learn',
                    ),
                    TopNavRoute(
                      icon: SailSVGAsset.settings,
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(child: child),
                    const StatusBar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    GetIt.I.get<BinaryProvider>().onShutdown(
          shutdownOptions: ShutdownOptions(
            router: GetIt.I.get<AppRouter>(),
            onComplete: () async {
              await windowManager.destroy();
            },
          ),
        );
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await GetIt.I.get<BinaryProvider>().onShutdown(
          shutdownOptions: ShutdownOptions(
            router: GetIt.I.get<AppRouter>(),
            onComplete: () async {
              await windowManager.destroy();
            },
          ),
        );
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> with ChangeNotifier, ChangeTrackingMixin {
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    initChangeTracker();
    blockchainProvider.addListener(_onChange);
    balanceProvider.addListener(_onChange);
    if (!Environment.isInTest) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    }
  }

  void _onChange() {
    track('lastBlockTime', blockchainProvider.syncProvider.mainchainSyncInfo?.lastBlockAt);
    track('peerCount', blockchainProvider.peers.length);
    notifyIfChanged();
  }

  String _getTimeSinceLastBlock() {
    if (blockchainProvider.syncProvider.mainchainSyncInfo?.lastBlockAt == null) {
      return 'Unknown';
    }

    final now = DateTime.now();
    final lastBlockTime = blockchainProvider.syncProvider.mainchainSyncInfo!.lastBlockAt!.toDateTime().toLocal();
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
      navigateToLogs: (title, logPath) {
        GetIt.I.get<AppRouter>().push(
              LogRoute(
                title: title,
                logPath: logPath,
              ),
            );
      },
      mainchainInfo: true,
      endWidgets: [
        SailSkeletonizer(
          description: 'Waiting for bitcoind to connect..',
          enabled: !blockchainProvider.mainchain.connected,
          child: Tooltip(
            message: blockchainProvider.blocks.firstOrNull?.toPretty() ?? '',
            child: SailText.secondary12('Last block: ${_getTimeSinceLastBlock()}'),
          ),
        ),
        const DividerDot(),
        SailSkeletonizer(
          description: 'Waiting for bitcoind to connect..',
          enabled: !blockchainProvider.mainchain.connected,
          child: Tooltip(
            message: blockchainProvider.peers.map((e) => 'Peer id=${e.id} addr=${e.addr}').join('\n'),
            child: SailText.secondary12(
              formatTimeDifference(blockchainProvider.peers.length, 'peer'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    blockchainProvider.removeListener(_onChange);
    balanceProvider.removeListener(_onChange);
    super.dispose();
  }
}

String formatTimeDifference(int value, String unit) {
  if (value < 0) {
    value = 0;
  }
  return '$value $unit${value == 1 ? '' : 's'}';
}

extension on Block {
  String toPretty() {
    return 'Block $height\nBlockTime=${blockTime.toDateTime().toLocal().format()}\nHash=$hash';
  }
}
