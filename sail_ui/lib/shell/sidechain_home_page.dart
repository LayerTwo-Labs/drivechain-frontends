import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart' as auto_router;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/run_sidechain_app.dart';
import 'package:sail_ui/shell/sidechain_module.dart';
import 'package:sail_ui/shell/sidechain_settings_page.dart';
import 'package:stacked/stacked.dart' show BaseViewModel, ViewModelBuilder;
import 'package:window_manager/window_manager.dart';

@RoutePage()
class SidechainHomePage extends StatefulWidget {
  const SidechainHomePage({super.key});

  @override
  State<SidechainHomePage> createState() => _SidechainHomePageState();
}

class _SidechainHomePageState extends State<SidechainHomePage> with WidgetsBindingObserver, WindowListener {
  BitcoinConfProvider get _confProvider => GetIt.I.get<BitcoinConfProvider>();
  SidechainRPC get sidechainRPC => GetIt.I.get<SidechainRPC>();
  SidechainModule get module => GetIt.I.get<SidechainModule>();
  ShellTabIndex get tabIndex => ShellTabIndex.of(module);

  bool _shutdownInProgress = false;
  DateTime? _lastShiftPress;
  final CodeSearchService _codeSearchService = CodeSearchService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWindowManager();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    _codeSearchService.loadFiles();
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
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

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyK) {
      final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
      final isControlPressed = HardwareKeyboard.instance.isControlPressed;

      if (Platform.isMacOS ? isMetaPressed : isControlPressed) {
        _openCommandPalette();
        return true;
      }
    }

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
    showThemedDialog(
      context: context,
      builder: (dialogContext) => SailCommandPalette(
        commands: [
          for (final cmd in _getMenuCommands(dialogContext))
            SailCommandPaletteItem(label: cmd.label, category: cmd.category, onSelected: cmd.onSelected),
        ],
        matches: (item, query) =>
            item.label.toLowerCase().contains(query) || item.category.toLowerCase().contains(query),
        searchResults: (query) => [
          for (final result in _codeSearchService.search(query))
            SailCommandPaletteItem(
              label: result.matchedLine,
              category: result.fileName,
              subtitle: 'Line ${result.lineNumber}',
              onSelected: () => _navigateToFileContext(result.filePath, result.matchedLine),
            ),
        ],
      ),
    );
  }

  void _navigateToFileContext(String filePath, String matchedLine) {
    final fileName = filePath.split('/').last;
    final target = shellNavigationRegistry(module)[fileName];

    if (target == null) {
      return;
    }

    AutoRouterX(context).tabsRouter.setActiveIndex(target.tabIndex);

    if (target.sectionIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SidechainSettingsPage.setSection(target.sectionIndex!);
      });
    }
  }

  List<CommandItem> _getMenuCommands(BuildContext dialogContext) {
    final router = GetIt.I.get<RootStackRouter>();
    final windowProvider = GetIt.I.get<WindowProvider>();

    return [
      CommandItem(
        label: 'Backup Wallet',
        category: 'Your Wallet',
        onSelected: () async {
          await router.push(BackupWalletRoute(appName: module.chain.registryKey));
        },
      ),
      CommandItem(
        label: 'Restore Wallet',
        category: 'Your Wallet',
        onSelected: () async {
          await router.push(
            SailCreateWalletRoute(
              homeRoute: const SidechainHomeRoute(),
              initialScreen: WelcomeScreen.restore,
              additionalRestoreOptionsBuilder: (context) => WalletBackupRestoreOptions(
                bootBinaries: (log) async => bootSidechainBinaries(module, log),
                binariesToStop: module.binariesToStop,
              ),
            ),
          );
        },
      ),

      CommandItem(
        label: 'Parent Chain',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.parentChain);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: module.homeTabLabel,
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.homepage);
          Navigator.of(dialogContext).pop();
        },
      ),
      for (final (n, tab) in module.tabs.indexed)
        CommandItem(
          label: tab.commandLabel ?? tab.label,
          category: 'Navigation',
          onSelected: () {
            AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.chainTab(n));
            Navigator.of(dialogContext).pop();
          },
        ),
      CommandItem(
        label: 'Console',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.console);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Settings',
        category: 'Navigation',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.settings);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Configure Homepage',
        category: 'Navigation',
        onSelected: () async {
          await router.push(SidechainConfigureHomepageRoute());
        },
      ),

      CommandItem(
        label: 'Open Debug Window',
        category: 'This Node',
        onSelected: () async {
          await windowProvider.open(SidechainSubWindows.debug);
        },
      ),
      CommandItem(
        label: 'View Logs',
        category: 'This Node',
        onSelected: () async {
          await windowProvider.open(SidechainSubWindows.logs);
        },
      ),
      CommandItem(
        label: openLogsLabel(),
        category: 'This Node',
        onSelected: openLogs,
      ),

      CommandItem(
        label: 'Appearance Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.settings);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Theme Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.settings);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Font Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.settings);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Bitcoin Unit Settings',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.settings);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'Reset ${module.appName} Data',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.settings);
          Navigator.of(dialogContext).pop();
        },
      ),
      CommandItem(
        label: 'About',
        category: 'Settings',
        onSelected: () {
          AutoRouterX(context).tabsRouter.setActiveIndex(tabIndex.settings);
          Navigator.of(dialogContext).pop();
        },
      ),

      CommandItem(
        label: 'Quit ${module.appName}',
        category: sidechainRPC.chain.name,
        shortcut: '⌘Q',
        onSelected: () => didRequestAppExit(),
      ),
    ];
  }

  Future<void> _initializeWindowManager() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Stack(
      children: [
        CrossPlatformMenuBar(
          menus: [
            PlatformMenu(
              label: sidechainRPC.chain.name,
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'About ${sidechainRPC.chain.name}',
                      onSelected: null,
                    ),
                  ],
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Quit ${sidechainRPC.chain.name}',
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true),
                      onSelected: () => didRequestAppExit(),
                    ),
                  ],
                ),
              ],
            ),

            PlatformMenu(
              label: 'Your Wallet',
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Backup Wallet',
                      onSelected: () async {
                        await GetIt.I.get<RootStackRouter>().push(
                          BackupWalletRoute(appName: module.chain.registryKey),
                        );
                      },
                    ),
                    PlatformMenuItem(
                      label: 'Restore Wallet',
                      onSelected: () async {
                        await GetIt.I.get<RootStackRouter>().push(
                          SailCreateWalletRoute(
                            homeRoute: const SidechainHomeRoute(),
                            initialScreen: WelcomeScreen.restore,
                            additionalRestoreOptionsBuilder: (context) => WalletBackupRestoreOptions(
                              bootBinaries: (log) async => bootSidechainBinaries(module, log),
                              binariesToStop: module.binariesToStop,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            PlatformMenu(
              label: 'This Node',
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Debug Window',
                      onSelected: () async {
                        final windowProvider = GetIt.I.get<WindowProvider>();
                        await windowProvider.open(SidechainSubWindows.debug);
                      },
                    ),
                    PlatformMenuItem(
                      label: 'View Logs',
                      onSelected: GetIt.I.get<WindowProvider>().logFile.existsSync()
                          ? () async {
                              final windowProvider = GetIt.I.get<WindowProvider>();
                              await windowProvider.open(SidechainSubWindows.logs);
                            }
                          : null,
                    ),
                    openLogsMenuItem(),
                  ],
                ),
              ],
            ),

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
          child: SailScaffold(
            backgroundColor: theme.colors.background,
            body: auto_router.AutoTabsRouter.builder(
              homeIndex: tabIndex.homepage,
              routes: shellTabRoutes(module),
              builder: (context, children, tabsRouter) {
                return ViewModelBuilder.reactive(
                  viewModelBuilder: () => SidechainHomePageViewModel(),
                  fireOnViewModelReadyOnce: true,
                  builder: (context, model, child) {
                    return SailScaffold(
                      backgroundColor: theme.colors.background,
                      appBar: TopNav(
                        routes: shellTopNavRoutes(module, tabsRouter.setActiveIndex),
                        endWidget: SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            SailDropdownButton<String>(
                              value: _confProvider.currentDrivechainOptionId,
                              items: [
                                for (final option in _confProvider.drivechainNetworkOptions)
                                  SailDropdownItem<String>(value: option.id, label: option.displayName),
                              ],
                              onChanged: (String? id) async {
                                if (id == null || _confProvider.hasPrivateBitcoinConf) {
                                  return;
                                }
                                await _confProvider.swapNetworkById(context, id);
                              },
                            ),
                            SailButton(
                              label: 'Configure Homepage',
                              small: true,
                              onPressed: () async {
                                await GetIt.I.get<RootStackRouter>().push(SidechainConfigureHomepageRoute());
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
                              rpc: sidechainRPC,
                              name: sidechainRPC.chain.name,
                            ),
                            navigateToLogs: (title, logPath, binaryType) {
                              GetIt.I.get<RootStackRouter>().push(
                                LogRoute(
                                  title: title,
                                  logPath: logPath,
                                  binaryType: binaryType,
                                ),
                              );
                            },
                            onOpenConfConfigurator: () {
                              GetIt.I.get<RootStackRouter>().push(BitcoinConfEditorRoute());
                            },
                            onOpenEnforcerConfConfigurator: () {
                              GetIt.I.get<RootStackRouter>().push(EnforcerConfEditorRoute());
                            },
                            onOpenAdditionalConfConfigurator: module.hasConfEditor
                                ? () {
                                    GetIt.I.get<RootStackRouter>().push(SidechainConfEditorRoute());
                                  }
                                : null,
                            endWidgets: [
                              ResetButton(
                                onTap: () async {
                                  SidechainSettingsPage.setSection(1);
                                  tabsRouter.setActiveIndex(tabIndex.settings);
                                },
                              ),
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
        ),
        const NotificationToastOverlay(),
      ],
    );
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    if (_shutdownInProgress) {
      await GetIt.I.get<BinaryProvider>().onShutdown(
        shutdownOptions: ShutdownOptions(
          router: GetIt.I.get<RootStackRouter>(),
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
      if (_shutdownInProgress) {
        await GetIt.I.get<BinaryProvider>().onShutdown(
          shutdownOptions: ShutdownOptions(
            router: GetIt.I.get<RootStackRouter>(),
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
          router: GetIt.I.get<RootStackRouter>(),
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

/// Tab indices of the shell: the common tabs around the chain tabs of the module.
class ShellTabIndex {
  final int chainTabCount;

  const ShellTabIndex(this.chainTabCount);

  ShellTabIndex.of(SidechainModule module) : chainTabCount = module.tabs.length;

  int get parentChain => 0;
  int get explorer => 1;
  int get bmm => 2;
  int get homepage => 3;
  int chainTab(int n) => homepage + 1 + n;
  int get console => homepage + 1 + chainTabCount;
  int get settings => console + 1;
}

List<PageRouteInfo> shellTabRoutes(SidechainModule module) => [
  ParentChainRoute(),
  ExplorerRoute(),
  BmmRoute(),
  SidechainHomepageRoute(),
  for (final tab in module.tabs) tab.route,
  ConsoleTabRoute(),
  SidechainSettingsRoute(),
];

List<TopNavRoute> shellTopNavRoutes(SidechainModule module, void Function(int index) select) {
  final index = ShellTabIndex.of(module);
  return [
    TopNavRoute(
      label: 'Parent Chain',
      onTap: () {
        select(index.parentChain);
      },
    ),
    TopNavRoute(
      label: 'Explorer',
      optionalKey: index.explorer,
      onTap: () {
        select(index.explorer);
      },
    ),
    TopNavRoute(
      label: 'BMM',
      optionalKey: index.bmm,
      onTap: () {
        select(index.bmm);
      },
    ),
    TopNavRoute(
      label: module.homeTabLabel,
      optionalKey: index.homepage,
      onTap: () {
        select(index.homepage);
      },
    ),
    for (final (n, tab) in module.tabs.indexed)
      TopNavRoute(
        label: tab.label,
        optionalKey: index.chainTab(n),
        onTap: () {
          select(index.chainTab(n));
        },
      ),
    TopNavRoute(
      label: 'Console',
      optionalKey: index.console,
      onTap: () {
        select(index.console);
      },
    ),
    TopNavRoute(
      icon: SailSVGAsset.settings,
    ),
  ];
}

class NavigationTarget {
  final int tabIndex;
  final int? sectionIndex;

  const NavigationTarget({required this.tabIndex, this.sectionIndex});
}

/// Maps a code search hit, by file name, to the tab that shows it.
Map<String, NavigationTarget> shellNavigationRegistry(SidechainModule module) {
  final index = ShellTabIndex.of(module);
  return {
    'settings_general.dart': NavigationTarget(tabIndex: index.settings, sectionIndex: 0),
    'settings_reset.dart': NavigationTarget(tabIndex: index.settings, sectionIndex: 1),
    'settings_info.dart': NavigationTarget(tabIndex: index.settings, sectionIndex: 2),
    'sidechain_homepage.dart': NavigationTarget(tabIndex: index.homepage),
    for (final file in module.homepageSourceFiles) file: NavigationTarget(tabIndex: index.homepage),
    for (final (n, tab) in module.tabs.indexed)
      for (final file in tab.sourceFiles) file: NavigationTarget(tabIndex: index.chainTab(n)),
    'console_tab.dart': NavigationTarget(tabIndex: index.console),
    'parent_chain_page.dart': NavigationTarget(tabIndex: index.parentChain),
  };
}

class SidechainHomePageViewModel extends BaseViewModel {
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainRPC get _rpc => GetIt.I.get<SidechainRPC>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  Binary get chain => _rpc.chain;

  SidechainHomePageViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}
