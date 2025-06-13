import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/debug_window.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/merchants/chain_merchants_dialog.dart';
import 'package:bitwindow/pages/message_signer.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/wallet/bitcoin_uri_dialog.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:bitwindow/widgets/address_list.dart';
import 'package:bitwindow/widgets/hash_calculator_modal.dart';
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
                    log.d('Changing theme...');

                    final themeSetting = await _clientSettings.getValue(ThemeSetting());
                    final currentTheme = themeSetting.value;
                    log.d('Current theme: $currentTheme');

                    final SailThemeValues nextTheme = currentTheme.toggleTheme();
                    log.d('Switching to theme: $nextTheme');

                    await _clientSettings.setValue(ThemeSetting().withValue(nextTheme));
                    await app.loadTheme(nextTheme);
                    log.d('Theme change complete');
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Hide bitwindow',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyH, meta: true),
                  onSelected: null,
                ),
                PlatformMenuItem(
                  label: 'Hide Others',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyH, meta: true, shift: true),
                  onSelected: null,
                ),
                PlatformMenuItem(
                  label: 'Show All',
                  onSelected: null,
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Quit bitwindow',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
                  onSelected: () => GetIt.I.get<BinaryProvider>().onShutdown(
                        onComplete: () => exit(0),
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
                  label: 'Sending Addresses',
                  onSelected: () {
                    final theme = SailTheme.of(context);
                    showDialog(
                      context: context,
                      barrierColor: theme.colors.background.withValues(alpha: 0.4),
                      builder: (context) => const SailPadding(
                        padding: EdgeInsets.all(SailStyleValues.padding64),
                        child: AddressBookTable(initialDirection: Direction.DIRECTION_SEND),
                      ),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Receiving Addresses',
                  onSelected: () {
                    final theme = SailTheme.of(context);
                    showDialog(
                      context: context,
                      barrierColor: theme.colors.background.withValues(alpha: 0.4),
                      builder: (context) => const SailPadding(
                        padding: EdgeInsets.all(SailStyleValues.padding64),
                        child: AddressBookTable(initialDirection: Direction.DIRECTION_RECEIVE),
                      ),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Address Book',
                  onSelected: () {
                    final theme = SailTheme.of(context);
                    showDialog(
                      context: context,
                      barrierColor: theme.colors.background.withValues(alpha: 0.4),
                      builder: (context) => const SailPadding(
                        padding: EdgeInsets.all(SailStyleValues.padding64),
                        child: AddressBookTable(),
                      ),
                    );
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
                      WalletPage.tabKey.currentState!.setIndex(0);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'Request Money',
                  onSelected: () {
                    final tabsRouter = _routerKey.currentState?.controller;
                    tabsRouter?.setActiveIndex(1);
                    if (WalletPage.tabKey.currentState != null) {
                      WalletPage.tabKey.currentState!.setIndex(1);
                    }
                  },
                ),
                PlatformMenuItem(
                  label: 'See Wallet Transactions',
                  onSelected: () {
                    final tabsRouter = _routerKey.currentState?.controller;
                    tabsRouter?.setActiveIndex(1);
                    if (WalletPage.tabKey.currentState != null) {
                      WalletPage.tabKey.currentState!.setIndex(2);
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
                      // Switch to wallet tab and send tab
                      final tabsRouter = _routerKey.currentState?.controller;
                      tabsRouter?.setActiveIndex(1);
                      if (WalletPage.tabKey.currentState != null) {
                        WalletPage.tabKey.currentState!.setIndex(0);
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
                    final applicationDir = await Environment.datadir();
                    final logFile = await getLogFile();

                    await showDialog(
                      context: _routerKey.currentContext!,
                      builder: (context) => SailPadding(
                        padding: EdgeInsets.only(
                          top: SailStyleValues.padding16,
                          left: SailStyleValues.padding16,
                          right: SailStyleValues.padding16,
                          bottom: SailStyleValues.padding64 * 2,
                        ),
                        child: DeniabilityTab(
                          newWindowIdentifier: NewWindowIdentifier(
                            windowType: 'deniability',
                            applicationDir: applicationDir,
                            logFile: logFile,
                          ),
                        ),
                      ),
                    );
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
                    showDialog(
                      context: context,
                      builder: (context) => const MessageSigner(),
                    );
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
                    final applicationDir = await Environment.datadir();
                    final logFile = await getLogFile();

                    await showDialog(
                      context: _routerKey.currentContext!,
                      builder: (context) => SailPadding(
                        padding: EdgeInsets.only(
                          top: SailStyleValues.padding16,
                          left: SailStyleValues.padding16,
                          right: SailStyleValues.padding16,
                          bottom: SailStyleValues.padding64 * 2,
                        ),
                        child: BlockExplorerDialog(
                          newWindowIdentifier: NewWindowIdentifier(
                            windowType: 'block_explorer',
                            applicationDir: applicationDir,
                            logFile: logFile,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Hash Calculator',
                  onSelected: () {
                    showDialog(
                      context: _routerKey.currentContext!,
                      builder: (context) => const HashCalculatorModal(),
                    );
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
                    final applicationDir = await Environment.datadir();
                    final logFile = await getLogFile();

                    await showDialog(
                      context: _routerKey.currentContext!,
                      builder: (context) => SailPadding(
                        padding: EdgeInsets.only(
                          top: SailStyleValues.padding16,
                          left: SailStyleValues.padding16,
                          right: SailStyleValues.padding16,
                          bottom: SailStyleValues.padding64 * 2,
                        ),
                        child: DebugWindow(
                          newWindowIdentifier: NewWindowIdentifier(
                            windowType: 'debug',
                            applicationDir: applicationDir,
                            logFile: logFile,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'View Logs',
                  onSelected: () => GetIt.I.get<AppRouter>().push(
                        LogRoute(
                          title: 'Bitwindow Logs',
                          logPath: BitWindow().logPath(),
                        ),
                      ),
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
      onComplete: () async {
        await windowManager.destroy();
      },
    );
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await GetIt.I.get<BinaryProvider>().onShutdown(
      onComplete: () async {
        await windowManager.destroy();
      },
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  void _onChange() {
    track('lastBlockTime', blockchainProvider.infoProvider.mainchainSyncInfo?.lastBlockAt);
    track('peerCount', blockchainProvider.peers.length);
    notifyIfChanged();
  }

  String _getTimeSinceLastBlock() {
    if (blockchainProvider.infoProvider.mainchainSyncInfo?.lastBlockAt == null) {
      return 'Unknown';
    }

    final now = DateTime.now();
    final lastBlockTime = blockchainProvider.infoProvider.mainchainSyncInfo!.lastBlockAt!.toDateTime().toLocal();
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
