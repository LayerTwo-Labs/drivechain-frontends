import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/debug_window.dart';
import 'package:bitwindow/pages/merchants/chain_merchants_dialog.dart';
import 'package:bitwindow/pages/message_signer.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/wallet/bitcoin_uri_dialog.dart';
import 'package:bitwindow/pages/wallet_page.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:bitwindow/widgets/address_list.dart';
import 'package:bitwindow/widgets/hash_calculator_modal.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pbenum.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/pages/router.gr.dart' as sailroutes;
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/bottom_nav.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';
import 'package:sail_ui/widgets/platform_menu.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final _routerKey = GlobalKey<AutoTabsRouterState>();
  final _binaryProvider = GetIt.I.get<BinaryProvider>();

  List<Topic> get topics => _newsProvider.topics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _binaryProvider.downloadThenBootL1(context, bootAllNoMatterWhat: true);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  onSelected: () => didRequestAppExit(),
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

                    final window = await DesktopMultiWindow.createWindow(
                      jsonEncode({
                        'window_type': 'deniability',
                        'application_dir': applicationDir.path,
                        'log_file': logFile.path,
                      }),
                    );
                    await window.setFrame(const Offset(0, 0) & const Size(1280, 720));
                    await window.center();
                    await window.setTitle('UTXOs and Denials');
                    await window.show();
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
                  onSelected: () => displayBroadcastNewsDialog(
                    context,
                    initialTopic: topics.isNotEmpty
                        ? topics[0]
                        : Topic(
                            id: Int64(1),
                            topic: 'US',
                            name: 'US Weekly',
                          ),
                  ),
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

                    final window = await DesktopMultiWindow.createWindow(
                      jsonEncode({
                        'window_type': 'block_explorer',
                        'application_dir': applicationDir.path,
                        'log_file': logFile.path,
                      }),
                    );
                    await window.setFrame(const Offset(0, 0) & const Size(1280, 720));
                    await window.center();
                    await window.setTitle('UTXOs and Denials');
                    await window.show();
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
        ],
        builder: (context, child, controller) {
          final theme = SailTheme.of(context);

          return SelectionArea(
            child: Scaffold(
              backgroundColor: theme.colors.background,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
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
                            label: 'Send / Receive',
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
            ),
          );
        },
      ),
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
        Tooltip(
          message: blockchainProvider.blocks.firstOrNull?.toPretty() ?? '',
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
