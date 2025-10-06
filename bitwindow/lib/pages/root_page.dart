import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/merchants/chain_merchants_dialog.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/wallet/bitcoin_uri_dialog.dart';
import 'package:bitwindow/widgets/proof_of_funds_modal.dart';
import 'package:bitwindow/widgets/cpu_mining_modal.dart';
import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/pages/welcome/create_wallet_page.dart';
import 'package:bitwindow/providers/bitwindow_settings_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver, WindowListener {
  final NewsProvider _newsProvider = GetIt.I.get<NewsProvider>();
  final HomepageProvider _homepageProvider = GetIt.I.get<HomepageProvider>();
  final BitwindowSettingsProvider _bitwindowSettingsProvider = GetIt.I.get<BitwindowSettingsProvider>();
  final _routerKey = GlobalKey<AutoTabsRouterState>();
  final _clientSettings = GetIt.I<ClientSettings>();

  NotificationProvider get _notificationProvider => GetIt.I.get<NotificationProvider>();
  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);

  List<Topic> get topics => _newsProvider.topics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationProvider.addListener(rebuildNotifications);
    _homepageProvider.addListener(_onProviderChanged);
    _bitwindowSettingsProvider.addListener(_onProviderChanged);
    _initializeWindowManager();
  }

  void _onProviderChanged() {
    setState(() {});
  }

  void rebuildNotifications() {
    notificationsNotifier.value = _notificationProvider.notifications;

    // call notifyListeners manually coz == on List<Widget> doesn't work..
    // ignore: invalid_use_of_protected_member,invalid_use_of_visible_for_testing_member
    notificationsNotifier.notifyListeners();
  }

  Future<void> _initializeWindowManager() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  @override
  Widget build(BuildContext context) {
    final app = SailApp.of(context);

    return Stack(
      children: [
        CrossPlatformMenuBar(
          key: ValueKey('crossPlatformMenuBar'),
          menus: [
            // First menu will be Apple menu (system provided)
            PlatformMenu(
              label: 'bitwindow',
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'About bitwindow',
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final theme = SailTheme.of(context);
                            return Dialog(
                              backgroundColor: theme.colors.backgroundSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: SailStyleValues.borderRadiusSmall,
                                side: BorderSide(
                                  color: theme.colors.border,
                                  width: 1,
                                ),
                              ),
                              child: Container(
                                width: 800,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary20('About Drivechain'),
                                    const SizedBox(height: 16),
                                    SelectableText.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colors.text,
                                          fontFamily: 'Inter',
                                          height: 1.5,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Drivechain version v0.47.00.0-unk (64-bit)\n\n'),
                                          const TextSpan(text: 'Copyright (C) 2009-2024 The Drivechain developers\n'),
                                          const TextSpan(
                                            text: 'Copyright (C) 2009-2024 The Bitcoin Core developers\n\n',
                                          ),
                                          const TextSpan(
                                            text: 'Please contribute if you find Drivechain useful. Visit ',
                                          ),
                                          TextSpan(
                                            text: 'http://drivechain.info',
                                            style: TextStyle(
                                              color: theme.colors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                await launchUrl(Uri.parse('http://drivechain.info'));
                                              },
                                          ),
                                          const TextSpan(text: ' for further information about the software.\n'),
                                          const TextSpan(
                                            text: 'The source code for this application is available from ',
                                          ),
                                          TextSpan(
                                            text: 'https://github.com/LayerTwo-Labs/drivechain-frontends',
                                            style: TextStyle(
                                              color: theme.colors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                await launchUrl(
                                                  Uri.parse('https://github.com/LayerTwo-Labs/drivechain-frontends'),
                                                );
                                              },
                                          ),
                                          const TextSpan(
                                            text: '. The source code for the underlying enforcer is available from ',
                                          ),
                                          TextSpan(
                                            text: 'https://github.com/LayerTwo-Labs/bip300301_enforcer',
                                            style: TextStyle(
                                              color: theme.colors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                await launchUrl(
                                                  Uri.parse('https://github.com/LayerTwo-Labs/bip300301_enforcer'),
                                                );
                                              },
                                          ),
                                          const TextSpan(text: '.\n\n'),
                                          const TextSpan(text: 'This is experimental software.\n'),
                                          const TextSpan(
                                            text:
                                                'Distributed under the MIT software license, see the accompanying file COPYING or ',
                                          ),
                                          TextSpan(
                                            text: 'https://opensource.org/licenses/MIT',
                                            style: TextStyle(
                                              color: theme.colors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                await launchUrl(Uri.parse('https://opensource.org/licenses/MIT'));
                                              },
                                          ),
                                          const TextSpan(text: '\n\n'),
                                          const TextSpan(
                                            text:
                                                'This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit ',
                                          ),
                                          TextSpan(
                                            text: 'https://www.openssl.org',
                                            style: TextStyle(
                                              color: theme.colors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                await launchUrl(Uri.parse('https://www.openssl.org'));
                                              },
                                          ),
                                          const TextSpan(
                                            text:
                                                ' and cryptographic software written by Eric Young and UPnP software written by Thomas Bernard.',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SailButton(
                                        onPressed: () async => Navigator.of(context).pop(),
                                        label: 'OK',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
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
                          onComplete: () async {
                            exit(0);
                          },
                          showShutdownPage: false,
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
                      label: 'Create New Wallet',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(
                          CreateWalletRoute(initalScreen: WelcomeScreen.initial),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Restore My Wallet',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(
                          CreateWalletRoute(initalScreen: WelcomeScreen.restore),
                        );
                      },
                    ),
                  ],
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Address Book',
                      onSelected: () {
                        final windowProvider = GetIt.I.get<WindowProvider>();
                        windowProvider.open(SubWindowTypes.addressbook);
                      },
                    ),
                    PlatformMenuItem(
                      label: 'HD Wallet Explorer',
                      onSelected: () {
                        final windowProvider = GetIt.I.get<WindowProvider>();
                        windowProvider.open(SubWindowTypes.hdWallet);
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
                    PlatformMenuItem(
                      label: 'Proof of Funds',
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ProofOfFundsModal(),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Multisig Lounge',
                      onSelected: () {
                        final windowProvider = GetIt.I.get<WindowProvider>();
                        windowProvider.open(SubWindowTypes.multisigLounge);
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
                    PlatformMenuItem(
                      label: 'BitDrive',
                      onSelected: () {
                        final windowProvider = GetIt.I.get<WindowProvider>();
                        windowProvider.open(SubWindowTypes.bitDrive);
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
                    PlatformMenuItem(
                      label: 'CPU Mining',
                      onSelected: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => const CpuMiningModal(),
                        );
                      },
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
            routes: [
              OverviewRoute(),
              WalletRoute(),
              SidechainsRoute(),
              LearnRoute(),
              ConsoleRoute(),
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
                          label: 'Console',
                        ),
                        TopNavRoute(
                          icon: SailSVGAsset.settings,
                        ),
                      ],
                      endWidget: SailRow(
                        children: [
                          SailButton(
                            onPressed: () async {
                              await _bitwindowSettingsProvider.incrementConfigureButtonPressCount();
                              await GetIt.I.get<AppRouter>().push(ConfigureHomeRoute());
                            },
                            variant: _bitwindowSettingsProvider.settings.shouldShowPrimaryButton
                                ? ButtonVariant.primary
                                : ButtonVariant.ghost,
                            label: 'Configure Home Page',
                            small: true,
                          ),
                          SailButton(
                            onPressed: () async {
                              await _showBlockTemplateModal(context);
                            },
                            variant: ButtonVariant.ghost,
                            label: 'Block Template',
                            small: true,
                          ),
                          SailButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse('https://t.me/DcInsiders'));
                            },
                            variant: ButtonVariant.icon,
                            icon: SailSVGAsset.telegram,
                            small: true,
                          ),
                        ],
                      ),
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
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: ValueListenableBuilder<List<Widget>>(
            valueListenable: notificationsNotifier,
            builder: (context, notifications, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: notifications,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showBlockTemplateModal(BuildContext context) async {
    final enforcer = GetIt.I.get<EnforcerRPC>();
    final theme = SailTheme.of(context);
    final log = GetIt.I.get<Logger>();

    // Show loading dialog
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: theme.colors.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: SailStyleValues.borderRadiusSmall,
            side: BorderSide(
              color: theme.colors.border,
              width: 1,
            ),
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.primary20('Loading Block Template...'),
                const SizedBox(height: 16),
                CircularProgressIndicator(color: theme.colors.primary),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final blockTemplate = await enforcer.getBlockTemplate();

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show result dialog
      if (context.mounted) {
        unawaited(
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: theme.colors.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: SailStyleValues.borderRadiusSmall,
                side: BorderSide(
                  color: theme.colors.border,
                  width: 1,
                ),
              ),
              child: Container(
                width: 800,
                height: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailText.primary20('Block Template'),
                        IconButton(
                          icon: Icon(Icons.close, color: theme.colors.text),
                          onPressed: () async => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          JsonEncoder.withIndent('  ').convert(blockTemplate),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colors.text,
                            fontFamily: 'IBMPlexMono',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SailButton(
                        onPressed: () async => Navigator.of(context).pop(),
                        label: 'Close',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      log.e('Failed to get block template: $e');

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show error dialog
      if (context.mounted) {
        unawaited(
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: theme.colors.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: SailStyleValues.borderRadiusSmall,
                side: BorderSide(
                  color: theme.colors.border,
                  width: 1,
                ),
              ),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary20('Error'),
                    const SizedBox(height: 16),
                    SelectableText(
                      'Failed to get block template:\n$e',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colors.error,
                        fontFamily: 'IBMPlexMono',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SailButton(
                        onPressed: () async => Navigator.of(context).pop(),
                        label: 'OK',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(_onProviderChanged);
    _bitwindowSettingsProvider.removeListener(_onProviderChanged);
    GetIt.I.get<BinaryProvider>().onShutdown(
      shutdownOptions: ShutdownOptions(
        router: GetIt.I.get<AppRouter>(),
        onComplete: () async {
          await windowManager.destroy();
        },
        showShutdownPage: true,
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
        showShutdownPage: true,
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
