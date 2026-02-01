import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/dialogs/command_palette_dialog.dart';
import 'package:truthcoin/main.dart';
import 'package:truthcoin/pages/tabs/settings_page.dart';
import 'package:truthcoin/routing/router.dart';
import 'package:truthcoin/services/code_search_service.dart';
import 'package:truthcoin/utils/menu_commands.dart';
import 'package:truthcoin/utils/navigation_registry.dart';
import 'package:truthcoin/widgets/reset_button.dart';
import 'package:window_manager/window_manager.dart';

// IMPORTANT: Update router.dart AND routes in HomePage further down
// in this file, when updating here. Route order should match exactly
enum Tabs {
  // parent chain routes
  ParentChainPeg,

  // truthcoin configurable homepage
  TruthcoinHomepage,

  // sidechain console route
  Console,

  // trailing common routes
  SettingsHome,
}

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver, WindowListener {
  NotificationProvider get _notificationProvider => GetIt.I.get<NotificationProvider>();
  BitcoinConfProvider get _confProvider => GetIt.I.get<BitcoinConfProvider>();
  TruthcoinRPC get truthcoinRPC => GetIt.I.get<TruthcoinRPC>();

  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);
  bool _shutdownInProgress = false;
  DateTime? _lastShiftPress;
  final CodeSearchService _codeSearchService = CodeSearchService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationProvider.addListener(rebuildNotifications);
    _initializeWindowManager();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    _codeSearchService.loadFiles();
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    // Double-shift detection
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight)) {
      final now = DateTime.now();
      if (_lastShiftPress != null && now.difference(_lastShiftPress!).inMilliseconds < 400) {
        _lastShiftPress = null;
        _openCommandPalette();
        return true;
      } else {
        _lastShiftPress = now;
      }
    }

    // Cmd+K / Ctrl+K
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyK) {
      final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
      final isControlPressed = HardwareKeyboard.instance.isControlPressed;

      if (Platform.isMacOS ? isMetaPressed : isControlPressed) {
        _openCommandPalette();
        return true;
      }
    }

    // Cmd+Shift+P / Ctrl+Shift+P
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyP) {
      final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
      final isControlPressed = HardwareKeyboard.instance.isControlPressed;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      if (isShiftPressed && (Platform.isMacOS ? isMetaPressed : isControlPressed)) {
        _openCommandPalette();
        return true;
      }
    }

    return false;
  }

  void _openCommandPalette() {
    showDialog(
      context: context,
      builder: (dialogContext) => CommandPaletteDialog(
        commands: _getMenuCommands(dialogContext),
        codeSearchService: _codeSearchService,
        onCodeResultSelected: (filePath, matchedLine) => _navigateToFileContext(filePath, matchedLine),
      ),
    );
  }

  void _navigateToFileContext(String filePath, String matchedLine) {
    final fileName = filePath.split('/').last;
    final target = navigationRegistry[fileName];

    if (target == null) return;

    AutoRouterX(context).tabsRouter.setActiveIndex(target.tabIndex);

    if (target.sectionIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SettingsTabPage.setSection(target.sectionIndex!);
      });
    }
  }

  List<CommandItem> _getMenuCommands(BuildContext dialogContext) {
    final router = GetIt.I.get<AppRouter>();
    final windowProvider = GetIt.I.get<WindowProvider>();

    return [
      // Your Wallet menu
      CommandItem(
        label: 'Restore My Wallet',
        category: 'Your Wallet',
        onSelected: () async {
          await router.push(
            SailCreateWalletRoute(
              homeRoute: const HomeRoute(),
              initialScreen: WelcomeScreen.restore,
            ),
          );
        },
      ),
      CommandItem(
        label: 'Backup Wallet',
        category: 'Your Wallet',
        onSelected: () async {
          await router.push(BackupWalletRoute(appName: 'truthcoin'));
        },
      ),
      CommandItem(
        label: 'Restore Wallet',
        category: 'Your Wallet',
        onSelected: () async {
          await router.push(
            RestoreWalletRoute(
              bootBinaries: (log) async => bootBinaries(log),
              binariesToStop: [BitcoinCore(), Enforcer(), Truthcoin()],
            ),
          );
        },
      ),

      // Navigation
      CommandItem(
        label: 'Parent Chain',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Overview',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.TruthcoinHomepage.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Console',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.Console.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Settings',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Configure Homepage',
        category: 'Navigation',
        onSelected: () async {
          await router.push(TruthcoinConfigureHomepageRoute());
        },
      ),

      // This Node menu
      CommandItem(
        label: 'Open Debug Window',
        category: 'This Node',
        onSelected: () async {
          await windowProvider.open(SubWindowTypes.debug);
        },
      ),
      CommandItem(
        label: 'View Logs',
        category: 'This Node',
        onSelected: () async {
          await windowProvider.open(SubWindowTypes.logs);
        },
      ),

      // Settings sections
      CommandItem(
        label: 'General Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Theme Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Font Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Bitcoin Unit Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Reset Truthcoin Data',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'App Info / About',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
          Navigator.of(dialogContext).pop();
        },
      ),

      // App menu
      CommandItem(
        label: 'Quit Truthcoin',
        category: truthcoinRPC.chain.name,
        shortcut: '⌘Q',
        onSelected: () => didRequestAppExit(),
      ),
    ];
  }

  Future<void> _initializeWindowManager() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
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

    return CrossPlatformMenuBar(
      menus: [
        PlatformMenu(
          label: truthcoinRPC.chain.name,
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'About ${truthcoinRPC.chain.name}',
                  onSelected: null,
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Quit ${truthcoinRPC.chain.name}',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
                  onSelected: () => didRequestAppExit(),
                ),
              ],
            ),
          ],
        ),

        // Your Wallet menu
        PlatformMenu(
          label: 'Your Wallet',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Restore My Wallet',
                  onSelected: () async {
                    await GetIt.I.get<AppRouter>().push(
                      SailCreateWalletRoute(
                        homeRoute: const HomeRoute(),
                        initialScreen: WelcomeScreen.restore,
                      ),
                    );
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Backup Wallet',
                  onSelected: () async {
                    await GetIt.I.get<AppRouter>().push(
                      BackupWalletRoute(appName: 'truthcoin'),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Restore Wallet',
                  onSelected: () async {
                    await GetIt.I.get<AppRouter>().push(
                      RestoreWalletRoute(
                        bootBinaries: (log) async => bootBinaries(log),
                        binariesToStop: [BitcoinCore(), Enforcer(), Truthcoin()],
                      ),
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

        // Help menu
        PlatformMenu(
          label: 'Help',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Search Commands...',
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyK,
                    meta: Platform.isMacOS,
                    control: !Platform.isMacOS,
                  ),
                  onSelected: () => _openCommandPalette(),
                ),
              ],
            ),
          ],
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.colors.background,
        body: auto_router.AutoTabsRouter.builder(
          homeIndex: Tabs.TruthcoinHomepage.index,
          routes: [
            // parent chain routes
            ParentChainRoute(),
            // truthcoin configurable homepage
            TruthcoinHomepageRoute(),
            // sidechain console route
            ConsoleTabRoute(),
            // trailing common routes
            SettingsTabRoute(),
          ],
          builder: (context, children, tabsRouter) {
            return ViewModelBuilder.reactive(
              viewModelBuilder: () => HomePageViewModel(),
              fireOnViewModelReadyOnce: true,
              builder: (context, model, child) {
                return Scaffold(
                  backgroundColor: theme.colors.background,
                  appBar: TopNav(
                    routes: [
                      TopNavRoute(
                        label: 'Parent Chain',
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index);
                        },
                      ),
                      TopNavRoute(
                        label: 'Overview',
                        optionalKey: Tabs.TruthcoinHomepage.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.TruthcoinHomepage.index);
                        },
                      ),
                      TopNavRoute(
                        label: 'Console',
                        optionalKey: Tabs.Console.index,
                        onTap: () {
                          tabsRouter.setActiveIndex(Tabs.Console.index);
                        },
                      ),
                      TopNavRoute(
                        icon: SailSVGAsset.settings,
                      ),
                    ],
                    endWidget: SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailDropdownButton<BitcoinNetwork>(
                          value: _confProvider.network,
                          items: [
                            SailDropdownItem<BitcoinNetwork>(
                              value: BitcoinNetwork.BITCOIN_NETWORK_FORKNET,
                              label: 'Forknet',
                            ),
                            SailDropdownItem<BitcoinNetwork>(
                              value: BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
                              label: 'Signet',
                            ),
                            SailDropdownItem<BitcoinNetwork>(
                              value: BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
                              label: 'Regtest',
                            ),
                          ],
                          onChanged: (BitcoinNetwork? network) async {
                            if (network == null || _confProvider.hasPrivateBitcoinConf) return;
                            await _confProvider.swapNetwork(context, network);
                          },
                        ),
                        SailButton(
                          label: 'Configure Homepage',
                          small: true,
                          onPressed: () async {
                            await GetIt.I.get<AppRouter>().push(TruthcoinConfigureHomepageRoute());
                          },
                        ),
                      ],
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(child: children[tabsRouter.activeIndex]),
                      BottomNav(
                        mainchainInfo: false,
                        additionalConnection: ConnectionMonitor(
                          rpc: truthcoinRPC,
                          name: truthcoinRPC.chain.name,
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
                        onOpenConfConfigurator: () {
                          GetIt.I.get<AppRouter>().push(BitcoinConfEditorRoute());
                        },
                        onOpenEnforcerConfConfigurator: () {
                          GetIt.I.get<AppRouter>().push(EnforcerConfEditorRoute());
                        },
                        onOpenAdditionalConfConfigurator: () {
                          GetIt.I.get<AppRouter>().push(TruthcoinConfEditorRoute());
                        },
                        endWidgets: const [
                          ResetButton(),
                        ],
                        onlyShowAdditional: true,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    // If shutdown is already in progress, trigger force-kill
    if (_shutdownInProgress) {
      await GetIt.I.get<BinaryProvider>().onShutdown(
        shutdownOptions: ShutdownOptions(
          router: GetIt.I.get<AppRouter>(),
          onComplete: () async {},
          showShutdownPage: false,
          forceKill: true,
        ),
      );
      return AppExitResponse.exit;
    }

    _shutdownInProgress = true;
    await GetIt.I.get<BinaryProvider>().onShutdown();
    return AppExitResponse.exit;
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // If shutdown is already in progress, trigger force-kill
      if (_shutdownInProgress) {
        await GetIt.I.get<BinaryProvider>().onShutdown(
          shutdownOptions: ShutdownOptions(
            router: GetIt.I.get<AppRouter>(),
            onComplete: () async {
              if (isPreventClose) {
                await windowManager.destroy();
              }
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
            if (isPreventClose) {
              await windowManager.destroy();
            }
          },
          showShutdownPage: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TruthcoinRPC get _rpc => GetIt.I.get<TruthcoinRPC>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Binary get chain => _rpc.chain;

  HomePageViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
