import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:bitnames/dialogs/command_palette_dialog.dart';
import 'package:bitnames/main.dart';
import 'package:bitnames/pages/tabs/settings_page.dart';
import 'package:bitnames/routing/router.dart';
import 'package:bitnames/services/code_search_service.dart';
import 'package:bitnames/utils/menu_commands.dart';
import 'package:bitnames/utils/navigation_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:window_manager/window_manager.dart';

// IMPORTANT: Update router.dart AND routes in HomePage further down
// in this file, when updating here. Route order should match exactly
enum Tabs {
  // parent chain routes
  ParentChainPeg,

  // bitnames homepage
  BitnamesHomepage,

  // sidechain balance/transfer route
  Bitnames,

  // bitnames messaging route
  Messaging,

  // sidechain balance/transfer route
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
  BitnamesRPC get _rpc => GetIt.I.get<BitnamesRPC>();
  bool _shutdownInProgress = false;
  DateTime? _lastShiftPress;
  final CodeSearchService _codeSearchService = CodeSearchService();

  final ValueNotifier<List<Widget>> notificationsNotifier = ValueNotifier([]);

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
          await router.push(BackupWalletRoute(appName: 'bitnames'));
        },
      ),
      CommandItem(
        label: 'Restore Wallet',
        category: 'Your Wallet',
        onSelected: () async {
          await router.push(
            RestoreWalletRoute(
              bootBinaries: (log) async => bootBinaries(log),
              binariesToStop: [BitcoinCore(), Enforcer(), BitNames()],
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
        label: 'Home',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.BitnamesHomepage.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'BitNames',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.Bitnames.index);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Messaging',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(Tabs.Messaging.index);
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
          await router.push(BitnamesConfigureHomepageRoute());
        },
      ),

      // This Node menu
      CommandItem(
        label: 'Open Console Window',
        category: 'This Node',
        onSelected: () async {
          await windowProvider.open(SubWindowTypes.console);
        },
      ),
      CommandItem(
        label: 'View Logs',
        category: 'This Node',
        onSelected: () async {
          await windowProvider.open(SubWindowTypes.logs);
        },
      ),

      // App menu
      CommandItem(
        label: 'Quit BitNames',
        category: _rpc.chain.name,
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

    return Stack(
      children: [
        // Your main app content
        CrossPlatformMenuBar(
          menus: [
            PlatformMenu(
              label: _rpc.chain.name,
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'About ${_rpc.chain.name}',
                      onSelected: null,
                    ),
                  ],
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Quit ${_rpc.chain.name}',
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
                          BackupWalletRoute(appName: 'bitnames'),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Restore Wallet',
                      onSelected: () async {
                        await GetIt.I.get<AppRouter>().push(
                          RestoreWalletRoute(
                            bootBinaries: (log) async => bootBinaries(log),
                            binariesToStop: [BitcoinCore(), Enforcer(), BitNames()],
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
                      label: 'Console',
                      onSelected: () async {
                        final windowProvider = GetIt.I.get<WindowProvider>();
                        await windowProvider.open(SubWindowTypes.console);
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
              homeIndex: Tabs.BitnamesHomepage.index,
              routes: [
                // parent chain routes
                ParentChainRoute(),
                // bitnames homepage
                BitnamesHomepageRoute(),
                // bitnames route
                BitnamesTabRoute(),
                // bitnames messaging route
                MessagingTabRoute(),
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
                            label: 'Home',
                            optionalKey: Tabs.BitnamesHomepage.index,
                            onTap: () {
                              tabsRouter.setActiveIndex(Tabs.BitnamesHomepage.index);
                            },
                          ),
                          TopNavRoute(
                            label: 'BitNames',
                            optionalKey: Tabs.Bitnames.index,
                            onTap: () {
                              tabsRouter.setActiveIndex(Tabs.Bitnames.index);
                            },
                          ),
                          TopNavRoute(
                            label: 'Messaging',
                            optionalKey: Tabs.Messaging.index,
                            onTap: () {
                              tabsRouter.setActiveIndex(Tabs.Messaging.index);
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
                        endWidget: SailButton(
                          label: 'Configure Homepage',
                          small: true,
                          onPressed: () async {
                            await GetIt.I.get<AppRouter>().push(BitnamesConfigureHomepageRoute());
                          },
                        ),
                      ),
                      body: Column(
                        children: [
                          Expanded(child: children[tabsRouter.activeIndex]),
                          BottomNav(
                            mainchainInfo: false,
                            onlyShowAdditional: true,
                            additionalConnection: ConnectionMonitor(
                              rpc: _rpc,
                              name: _rpc.chain.name,
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
                              GetIt.I.get<AppRouter>().push(BitnamesConfEditorRoute());
                            },
                            endWidgets: [],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        // Notification stack overlay
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
  BitnamesRPC get _rpc => GetIt.I.get<BitnamesRPC>();

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
