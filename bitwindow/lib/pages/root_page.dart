import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/dialogs/base58_decoder_dialog.dart';
import 'package:bitwindow/dialogs/change_password_dialog.dart';
import 'package:bitwindow/dialogs/encrypt_wallet_dialog.dart';
import 'package:bitwindow/dialogs/merkle_tree_dialog.dart';
import 'package:bitwindow/dialogs/network_statistics_dialog.dart';
import 'package:bitwindow/dialogs/paper_wallet_dialog.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/merchants/chain_merchants_dialog.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/settings_page.dart';
import 'package:bitwindow/pages/wallet/bitcoin_uri_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/proof_of_funds_modal.dart';
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
  final BitcoinConfProvider _confProvider = GetIt.I.get<BitcoinConfProvider>();
  final _routerKey = GlobalKey<AutoTabsRouterState>();
  final _clientSettings = GetIt.I<ClientSettings>();

  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();
  NotificationProvider get _notificationProvider => GetIt.I.get<NotificationProvider>();
  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);
  bool _shutdownInProgress = false;
  bool _isWalletSwitching = false;
  bool _isWalletEncrypted = false;

  List<Topic> get topics => _newsProvider.topics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationProvider.addListener(rebuildNotifications);
    _homepageProvider.addListener(_onProviderChanged);
    _bitwindowSettingsProvider.addListener(_onProviderChanged);
    _walletReader.addListener(_onProviderChanged);
    _initializeWindowManager();
    _checkEncryptionStatus();
  }

  void _onProviderChanged() {
    _checkEncryptionStatus();
    setState(() {});
  }

  Future<void> _checkEncryptionStatus() async {
    final encrypted = await _walletReader.isWalletEncrypted();
    if (mounted && encrypted != _isWalletEncrypted) {
      setState(() {
        _isWalletEncrypted = encrypted;
      });
    }
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
                                            text: 'https://drivechain.info',
                                            style: TextStyle(
                                              color: theme.colors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                await launchUrl(Uri.parse('https://drivechain.info'));
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
                    PlatformMenuItem(
                      label: 'Configure Home Page',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(ConfigureHomeRoute());
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
                          CreateAnotherWalletRoute(),
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
                    if (!_isWalletEncrypted)
                      PlatformMenuItem(
                        label: 'Encrypt Wallet',
                        onSelected: () {
                          showDialog(
                            context: context,
                            builder: (context) => const EncryptWalletDialog(),
                          );
                        },
                      ),
                    if (_isWalletEncrypted)
                      PlatformMenuItem(
                        label: 'Change Password',
                        onSelected: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ChangePasswordDialog(),
                          );
                        },
                      ),
                    if (_isWalletEncrypted)
                      PlatformMenuItem(
                        label: 'Remove Encryption',
                        onSelected: () {
                          GetIt.I.get<AppRouter>().push(RemoveEncryptionRoute());
                        },
                      ),
                    PlatformMenuItem(
                      label: 'Backup Wallet',
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) => const BackupWalletDialog(),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Restore Wallet',
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) => const RestoreWalletDialog(),
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
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Paper Wallet',
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) => const PaperWalletDialog(),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Write a Check',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(CreateCheckRoute());
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
                      label: 'CPU Miner',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(CpuMiningRoute());
                      },
                    ),
                    PlatformMenuItem(
                      label: 'M4 Explorer',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(M4ExplorerRoute());
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Broadcast CoinNews',
                      onSelected: () => displayBroadcastNewsDialog(context),
                    ),
                    PlatformMenuItem(
                      label: 'Timestamp File(s)',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(const CreateTimestampRoute());
                      },
                    ),
                  ],
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenu(
                      label: 'Blockchain Data Storage',
                      menus: [
                        PlatformMenuItem(
                          label: 'OP_RETURN Graffiti',
                          onSelected: () {
                            showDialog(
                              context: context,
                              builder: (context) => const Dialog(
                                child: SizedBox(
                                  width: 900,
                                  height: 700,
                                  child: GraffitiExplorerView(),
                                ),
                              ),
                            );
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

            // Work for Bitcoin menu
            PlatformMenu(
              label: 'Work for Bitcoin',
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Solo Mine',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(CpuMiningRoute());
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Network Statistics',
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) => const NetworkStatisticsPage(),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Sidechain Activation',
                      onSelected: () {
                        GetIt.I.get<AppRouter>().push(SidechainActivationManagementRoute());
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Sidechain Withdrawal Admin',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(M4ExplorerRoute());
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
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) => const MerkleTreeDialog(),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Signatures',
                      onSelected: null,
                    ),
                    PlatformMenuItem(
                      label: 'Base58Check Decoder',
                      onSelected: () {
                        showDialog(
                          context: context,
                          builder: (context) => const Base58DecoderDialog(),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'CPU Mining',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(CpuMiningRoute());
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
                      label: 'Options',
                      onSelected: () {
                        final tabsRouter = _routerKey.currentState?.controller;
                        tabsRouter?.setActiveIndex(5);
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Command-line options',
                      onSelected: null,
                    ),
                  ],
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'View Logs',
                      onSelected: GetIt.I.get<WindowProvider>().logFile.existsSync()
                          ? () async {
                              final windowProvider = GetIt.I.get<WindowProvider>();
                              await windowProvider.open(SubWindowTypes.logs);
                            }
                          : null,
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
                      leadingWidget: _isWalletSwitching
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: LoadingIndicator.insideButton(theme.colors.primary),
                                ),
                                const SizedBox(width: 12),
                                SailText.primary13('Switching wallet...', bold: true),
                              ],
                            )
                          : WalletDropdown(
                              currentWallet: _walletReader.availableWallets
                                  .where((w) => w.id == _walletReader.activeWalletId)
                                  .firstOrNull,
                              availableWallets: _walletReader.availableWallets,
                              onWalletSelected: (walletId) async {
                                if (_isWalletSwitching) return;

                                final log = GetIt.I.get<Logger>();
                                log.i('Switching to wallet: $walletId');

                                // Show loading immediately and schedule the actual switch
                                setState(() => _isWalletSwitching = true);

                                // Run the switch in a microtask to allow UI to update first
                                await Future.microtask(() async {
                                  try {
                                    // Clear previous wallet data FIRST
                                    GetIt.I.get<TransactionProvider>().clear();
                                    GetIt.I.get<BalanceProvider>().clear();

                                    // Step 1: Switch the active wallet (updates UI immediately)
                                    log.i('Step 1: Switching active wallet');
                                    await _walletReader
                                        .switchWallet(walletId)
                                        .timeout(
                                          const Duration(seconds: 5),
                                          onTimeout: () => throw TimeoutException('switchWallet timed out'),
                                        );
                                    log.i('Step 1: Complete');

                                    // Reset providers in background
                                    unawaited(() async {
                                      try {
                                        log.i('Step 2: Refreshing balance provider');
                                        final balanceProvider = GetIt.I.get<BalanceProvider>();
                                        await balanceProvider.fetch();
                                        log.i('Step 2: Complete');
                                      } catch (e) {
                                        log.w('Step 2: Failed to refresh balance: $e');
                                      }

                                      try {
                                        log.i('Step 3: Refreshing transaction provider');
                                        final transactionProvider = GetIt.I.get<TransactionProvider>();
                                        await transactionProvider.fetch();
                                        log.i('Step 3: Complete');
                                      } catch (e) {
                                        log.w('Step 3: Failed to refresh transactions: $e');
                                      }
                                    }());

                                    log.i('Wallet switch complete (background tasks continuing)');
                                  } catch (e, stack) {
                                    log.e('Failed to switch wallet: $e\n$stack');
                                  } finally {
                                    // Hide loading after core operations complete
                                    if (mounted) {
                                      setState(() => _isWalletSwitching = false);
                                    }
                                  }
                                });
                              },
                              onCreateWallet: () async {
                                await GetIt.I.get<AppRouter>().push(CreateAnotherWalletRoute());
                              },
                              onBackgroundChanged: (walletId, newBackgroundSvg) async {
                                final wallet = _walletReader.availableWallets
                                    .where((w) => w.id == walletId)
                                    .firstOrNull;
                                if (wallet != null) {
                                  final updatedGradient = wallet.gradient.copyWith(
                                    backgroundSvg: newBackgroundSvg,
                                  );
                                  await _walletReader.updateWalletMetadata(
                                    walletId,
                                    wallet.name,
                                    updatedGradient,
                                  );
                                }
                              },
                            ),
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
                          SailDropdownButton<BitcoinNetwork>(
                            value: _confProvider.network,
                            items: [
                              SailDropdownItem<BitcoinNetwork>(
                                value: BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
                                label: 'Mainnet',
                              ),
                              SailDropdownItem<BitcoinNetwork>(
                                value: BitcoinNetwork.BITCOIN_NETWORK_FORKNET,
                                label: 'Forknet',
                              ),
                              SailDropdownItem<BitcoinNetwork>(
                                value: BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
                                label: 'Signet',
                              ),
                              SailDropdownItem<BitcoinNetwork>(
                                value: BitcoinNetwork.BITCOIN_NETWORK_TESTNET,
                                label: 'Testnet',
                              ),
                            ],
                            onChanged: (BitcoinNetwork? network) async {
                              if (network == null || !_confProvider.canEditNetwork) return;

                              await _confProvider.restartServicesWithProgress(
                                network,
                                (status) => setState(() {}),
                              );
                            },
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

  @override
  void dispose() {
    _homepageProvider.removeListener(_onProviderChanged);
    _bitwindowSettingsProvider.removeListener(_onProviderChanged);
    _walletReader.removeListener(_onProviderChanged);
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
    // If shutdown is already in progress, trigger force-kill
    if (_shutdownInProgress) {
      await GetIt.I.get<BinaryProvider>().onShutdown(
        shutdownOptions: ShutdownOptions(
          router: GetIt.I.get<AppRouter>(),
          onComplete: () async {
            await windowManager.destroy();
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
  Timer? _timer;

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
      navigateToLogs: (title, logPath, binaryType) {
        GetIt.I.get<AppRouter>().push(
          LogRoute(
            title: title,
            logPath: logPath,
            binaryType: binaryType,
          ),
        );
      },
      mainchainInfo: true,
      balanceEndWidgets: const [
        GetCoinsButton(),
      ],
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
    _timer?.cancel();
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
