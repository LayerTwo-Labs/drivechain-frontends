// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/pages/router.gr.dart' as sail_routes;
import 'package:sail_ui/shell/chain_events.dart';
import 'package:bitwindow/sidechains/hosted_modules.dart';
import 'package:bitwindow/sidechains/truthcoin_links.dart';
import 'package:bitwindow/sidechains/hosted_chains.dart';
import 'package:bitwindow/pages/sidechain_host_page.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/log_window.dart';
import 'package:bitwindow/sub_window_host.dart';
import 'package:sidechain_core/utils/hidden_window_timers.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:bitwindow/pages/debug_window.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/message_signer.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/pages/wallet/wallet_hd.dart';
import 'package:bitwindow/pages/wallet/wallet_multisig_lounge.dart';
import 'package:bitwindow/pages/wallet/bitdrive_page.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:bitwindow/providers/fast_withdrawal_provider.dart';
import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:bitwindow/providers/ecash_migration_provider.dart';
import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:bitwindow/providers/peers_provider.dart';
import 'package:bitwindow/providers/check_provider.dart';
import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:bitwindow/providers/content_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/homepage_provider.dart';
import 'package:bitwindow/providers/m4_provider.dart';
import 'package:bitwindow/providers/mempool_provider.dart';
import 'package:bitwindow/providers/mempool_watch_provider.dart';
import 'package:bitwindow/providers/mining_pools_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/providers/notification_stream_provider.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/consolidation_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/services/boot_snapshot.dart';
import 'package:bitwindow/services/bitwindowd_start.dart';
import 'package:bitwindow/services/daemon_warm_up.dart';
import 'package:bitwindow/widgets/address_list.dart';
import 'package:bitwindow/widgets/backend_swap.dart';
import 'package:bitwindow/widgets/datadir_network_notice.dart';
import 'package:bitwindow/widgets/ecash_upgrade_banner.dart';
import 'package:bitwindow/widgets/converter_window.dart';
import 'package:bitwindow/widgets/hash_calculator_modal.dart';
// App shell needs MaterialApp + ThemeData; Colors/Scaffold serve the
// ancestor-independent error boundary. Everything below uses sail_ui.
// ignore: drivechain_lints/avoid_material_import
import 'package:flutter/material.dart' show Colors, MaterialApp, Scaffold, ThemeData, VisualDensity;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/fonts.dart';
import 'package:sidechain_core/providers/price_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/legacy.dart';

/// The accent the app wears on a network. It is the colour that network
/// carries, so the picker and the app agree on what marks a chain.
///
/// A network with no colour of its own wears grey.
Color getNetworkAccentColor(BitcoinNetwork network) {
  return network.toColor() ?? SailColorScheme.greyMiddle;
}

void main(List<String> args) async {
  final subWindowTimers = Platform.isMacOS && args.firstOrNull == 'multi_window' ? HiddenWindowTimers() : null;
  // Some connectrpc/HTTP2 codepaths surface transient socket errors as
  // unhandled future errors during boot (the daemons aren't listening yet).
  // Catch them in a zone so they don't print giant red stack traces.
  await runZonedGuarded(
    () async {
      await withWindowsFileRetry(() async {
        try {
          WidgetsFlutterBinding.ensureInitialized();

          // The main window gets no entrypoint arguments, so it needs no window controller.
          final windowController = args.isEmpty ? null : await WindowController.fromCurrentEngine();

          final (applicationDir, logFile, log) = await init(windowController?.arguments ?? '');
          if (subWindowTimers != null) {
            return await runPooledSubWindow(windowController!, subWindowTimers, log, logFile);
          }

          // If arguments are not empty, this is a sub-window
          if (windowController != null && windowController.arguments.isNotEmpty) {
            return runMultiWindow(windowController.arguments, log, applicationDir, logFile);
          }

          await runMainWindow(log, applicationDir, logFile);
        } catch (e, stackTrace) {
          runErrorScreen(e, stackTrace);
        }
      });
    },
    (error, stack) {
      if (isExpectedBootError(error)) {
        return;
      }
      // Unexpected — keep the existing behavior of surfacing it.
      // ignore: avoid_print
      print('Unhandled error: $error\n$stack');
    },
    zoneSpecification: subWindowTimers?.zoneSpecification,
  );
}

final _daemonWarmUp = DaemonWarmUp();

/// The state of the last session, when the root page can show before the backend answers.
BootSnapshot? _rootSnapshot;

/// Runs a macOS sub-window engine that the main window can give a new page
/// after each close.
Future<void> runPooledSubWindow(
  WindowController windowController,
  HiddenWindowTimers timers,
  Logger log,
  File logFile,
) async {
  final windows = GetIt.I.get<WindowProvider>();
  final logCursors = <int, int>{};
  final host = SubWindowHost(
    controller: windowController,
    timers: timers,
    buildPage: (arguments) {
      final page = subWindowPage(arguments, logFile, logCursors);
      return (app: buildSailWindowApp(log, page.title, page.child, _subWindowAccent), work: page.work);
    },
    announceShown: () => windows.sendMessageToMain(windowShownMethod, null),
    announceHidden: (windowType) => announceHiddenWindow(windowController.windowId, windowType),
  );
  await host.start();
  await windowController.setWindowMethodHandler((call) async {
    if (call.method != openSpareMethod) {
      throw MissingPluginException('sub-window has no method ${call.method}');
    }
    await GetIt.I.get<SettingsProvider>().reload();
    unawaited(GetIt.I.get<BitcoinConfProvider>().loadConfig());
    refetchBuiltOnOpen();
    await host.open(jsonDecode(call.arguments as String) as Map<String, dynamic>);
    return null;
  });
  if (!isSpareWindowArguments(windowController.arguments)) {
    return host.open(jsonDecode(windowController.arguments) as Map<String, dynamic>);
  }
  timers.pause();
  await announceSpareWindow(windowController.windowId);
}

Future<(Directory, File, Logger)> init(String arguments) async {
  addFontLicense();
  await findSystemLocale();
  await initializeDateFormatting();

  Directory? applicationDir;
  File? logFile;
  bool isSubWindow = false;

  // If arguments are not empty, parse them for sub-window mode
  if (arguments.isNotEmpty) {
    isSubWindow = true;
    final parsedArgs = jsonDecode(arguments) as Map<String, dynamic>;

    if (parsedArgs['application_dir'] != null) {
      applicationDir = Directory(parsedArgs['application_dir']);
    }
    if (parsedArgs['log_file'] != null) {
      logFile = File(parsedArgs['log_file']);
    }

    if (logFile == null || applicationDir == null) {
      throw ArgumentError('Missing required arguments for multi-window mode: application_dir, log_file');
    }
  }

  // Fall back to filesystem if not provided in args
  applicationDir ??= await Environment.datadir();
  if (!isSubWindow) {
    final snapshot = BootSnapshot.read(applicationDir);
    _rootSnapshot = snapshot != null && snapshot.showsRootAtOnce ? snapshot : null;
  }
  // Point local-auth at the cookie beside wallet.json so every RPC carries it.
  LocalAuth.configure(applicationDir);
  logFile ??= await getLogFile();

  final log = await logger(Environment.fileLog, Environment.consoleLog, logFile);
  log.i('starting bitwindow, writing logs to $logFile');

  Environment.validateAtRuntime();

  final storage = await KeyValueStore.create(dir: applicationDir);

  // A sub-window builds a provider at its first read, so it runs only the
  // polls of its own page.
  void put<T extends Object>(T Function() create) {
    if (isSubWindow) {
      GetIt.I.registerLazySingleton<T>(create);
    } else {
      GetIt.I.registerSingleton<T>(create());
    }
  }

  void putScoped<T extends Object>(T Function() create) {
    if (!isSubWindow) {
      NetworkScopedRegistry.register<T>(create());
      return;
    }
    GetIt.I.registerLazySingleton<T>(() {
      final provider = create();
      if (provider is NetworkScoped) {
        NetworkScopedRegistry.enrol<NetworkScoped>(provider);
      }
      return provider;
    });
  }

  var refetchWired = false;
  T refetchOnNewBlock<T extends Object>(T provider) {
    if (!isSubWindow || refetchWired) {
      return provider;
    }
    refetchWired = true;
    scheduleMicrotask(() => GetIt.I<SyncProvider>().onNewBlock((_) => refetchBuiltOnNewBlock()));
    return provider;
  }

  // Register the logger
  GetIt.I.registerLazySingleton<Logger>(() => log);
  final windowProvider = await WindowProvider.newInstance(logFile, applicationDir, isMainWindow: !isSubWindow);
  GetIt.I.registerLazySingleton<WindowProvider>(() => windowProvider);
  GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());
  GetIt.I.registerLazySingleton<ClientSettings>(() => ClientSettings(store: storage, log: log));
  GetIt.I.registerLazySingleton<BitwindowClientSettings>(() => BitwindowClientSettings(store: storage, log: log));
  final settingsProvider = await SettingsProvider.create();
  GetIt.I.registerLazySingleton<SettingsProvider>(() => settingsProvider);
  GetIt.I.registerLazySingleton<FormatterProvider>(() => FormatterProvider(settingsProvider));

  // Initialize BitcoinConfProvider eagerly to load config before UI renders
  BitcoinConfProvider.promptForDataDir = promptForBitcoinDataDir;
  final bitcoinConfProvider = await BitcoinConfProvider.create(
    GetIt.I.get<AppRouter>(),
    restored: _rootSnapshot?.restoredConfig,
  );
  GetIt.I.registerLazySingleton<BitcoinConfProvider>(() => bitcoinConfProvider);

  // Initialize EnforcerConfProvider to load enforcer config
  final enforcerConfProvider = await EnforcerConfProvider.create();
  GetIt.I.registerLazySingleton<EnforcerConfProvider>(() => enforcerConfProvider);

  GetIt.I.registerLazySingleton<ContentProvider>(() => ContentProvider());
  GetIt.I.registerLazySingleton<PriceProvider>(() => PriceProvider());
  GetIt.I.registerLazySingleton<NotificationProvider>(() => NotificationProvider());
  GetIt.I.registerLazySingleton<NotificationActions>(
    () => NotificationActions(
      {
        ecashUpgradeAction: openECashUpgrade,
        datadirNetworkAction: openDatadirNetworkSwitch,
        sidechainTabAction: sidechainTabHandler(
          moduleFor: hostedModuleByKey,
          navigatorFor: (module) => HostChainNavigator(module.chain),
        ),
      },
      ownDialogs: const {datadirNetworkAction},
    ),
  );

  // Load chains config from JSON (copies seed from assets if missing)
  final chainsConfigProvider = await ChainsConfigProvider.create(
    appDir: applicationDir,
    paranoidMode: settingsProvider.bitwindowSettings.paranoidMode,
  );
  GetIt.I.registerSingleton<ChainsConfigProvider>(chainsConfigProvider);

  if (!isSubWindow) {
    await copyBinariesFromAssets(log, applicationDir, onStaged: _daemonWarmUp.onStaged);
  }

  // Register LogProvider for process output capture
  GetIt.I.registerSingleton<LogProvider>(LogProvider());

  // Load initial binary states
  final binaryProvider = await BinaryProvider.create(
    appDir: applicationDir,
    initialBinaries: initalBinaries(),
    shutdownEnabled: !isSubWindow,
    upChecks: {
      BinaryType.BINARY_TYPE_BITWINDOWD: tcpUpCheck(Environment.bitwindowdHost.value, Environment.bitwindowdPort.value),
    },
  );
  GetIt.I.registerSingleton<BinaryProvider>(binaryProvider);
  put<BitcoindConnection>(() => BitcoindConnection());
  // Enforcer services are bridged by bitwindowd — same endpoint as BitwindowRPC.
  put<EnforcerRPC>(
    () => EnforcerLive(host: Environment.bitwindowdHost.value, port: Environment.bitwindowdPort.value),
  );
  // Shared system boundary for runtime and wallet flows used across apps.
  final orchestrator = OrchestratorRPC(
    host: Environment.orchestratorHost.value,
    port: Environment.orchestratorPort.value,
  );
  GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
  // Eager, and after the orchestrator it polls: nothing ever resolves it.
  put<ECashUpgradeWatcher>(() => ECashUpgradeWatcher());
  put<BackendStateProvider>(() => BackendStateProvider(orchestrator));

  final bitwindow = BitwindowRPCLive(host: Environment.bitwindowdHost.value, port: Environment.bitwindowdPort.value);
  GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);

  // bitwindow applies the swap through bitwindowd so it recycles its
  // per-network database in the same step.
  bitcoinConfProvider.networkSwapper = (network, dataDir, networkId) =>
      bitwindow.bitwindowd.updateNetwork(network, dataDir: dataDir, networkId: networkId);

  // now register all sidedchains
  put<BitAssetsRPC>(() => BitAssetsLive());
  put<BitnamesRPC>(() => BitnamesLive());
  put<ThunderRPC>(() => ThunderLive());
  put<ZSideRPC>(() => ZSideLive());
  put<CoinShiftRPC>(() => CoinShiftLive());
  put<PhotonRPC>(() => PhotonLive());
  put<TruthcoinRPC>(() => TruthcoinLive());

  registerNodeMode();
  // After the node mode: the watcher reads it at the first check, and the mode
  // decides whether any process reads the blocks.
  put<DatadirNetworkWatcher>(() => DatadirNetworkWatcher());

  final walletReader = WalletReaderProvider(applicationDir);
  GetIt.I.registerLazySingleton<WalletReaderProvider>(() => walletReader);
  NetworkScopedRegistry.enrol(walletReader);
  _rootSnapshot?.restore(nodeMode: GetIt.I.get<NodeModeProvider>(), walletReader: walletReader);
  await walletReader.init();

  GetIt.I.registerLazySingleton<CoreVariantProvider>(() => CoreVariantProvider());
  GetIt.I.registerLazySingleton<ElectrumServerProvider>(() => ElectrumServerProvider());
  GetIt.I.registerLazySingleton<TorConfigProvider>(() => TorConfigProvider());

  final walletWriter = WalletWriterProvider(bitwindowAppDir: applicationDir);
  GetIt.I.registerLazySingleton<WalletWriterProvider>(() => walletWriter);
  await walletWriter.init();

  put<HwiProvider>(() => HwiProvider());

  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => refetchOnNewBlock(
      BalanceProvider(
        mainConnection: bitwindow,
        connections: [
          bitwindow,
          GetIt.I.get<BitnamesRPC>(),
          GetIt.I.get<BitAssetsRPC>(),
          GetIt.I.get<ThunderRPC>(),
          GetIt.I.get<ZSideRPC>(),
          GetIt.I.get<PhotonRPC>(),
          GetIt.I.get<TruthcoinRPC>(),
          GetIt.I.get<CoinShiftRPC>(),
        ],
      ),
    ),
  );
  GetIt.I.registerLazySingleton<SyncProvider>(
    () => SyncProvider(
      additionalConnection: SyncConnection(rpc: bitwindow, name: bitwindow.binary.name),
    ),
  );
  NetworkScopedRegistry.enrolLazy<BalanceProvider>();
  NetworkScopedRegistry.enrolLazy<SyncProvider>();
  GetIt.I.registerLazySingleton<DownloadProvider>(() => DownloadProvider());
  putScoped<PeersProvider>(() => PeersProvider());
  putScoped<BlockchainProvider>(() => refetchOnNewBlock(BlockchainProvider()));
  put<NetworkProvider>(() => NetworkProvider());
  putScoped<TransactionProvider>(() => refetchOnNewBlock(TransactionProvider()));

  // Refetch live on every new mainchain block so the user sees fresh blocks,
  // balance, and transactions without waiting for each provider's slower
  // independent poll (#1766). SyncProvider's onNewBlock fires only on a
  // strict height increment, so this is a no-op outside of actual new-block
  // events. Tracked here in main so the wiring is explicit and one-shot.
  if (!isSubWindow) {
    GetIt.I<SyncProvider>().onNewBlock((_) {
      unawaited(GetIt.I<BalanceProvider>().fetch());
      unawaited(GetIt.I<BlockchainProvider>().fetch());
      if (GetIt.I.isRegistered<TransactionProvider>()) {
        unawaited(GetIt.I<TransactionProvider>().fetch());
      }
    });
  }
  put<NewsProvider>(() => NewsProvider());
  putScoped<SidechainProvider>(() => SidechainProvider());
  put<M4Provider>(() => M4Provider());
  putScoped<AddressBookProvider>(() => AddressBookProvider());
  put<CoinSelectionProvider>(() => CoinSelectionProvider());
  // Coin selection runs in drivechaind, so a send hands it the frozen set
  // first. Every frontend send reaches it through this one client.
  GetIt.I.get<OrchestratorRPC>().wallet.frozenCoins = () async {
    final coins = GetIt.I.get<CoinSelectionProvider>();
    await coins.refresh();
    return coins.frozenOutpoints.toList();
  };
  putScoped<ConsolidationProvider>(() => ConsolidationProvider());
  put<StratumProvider>(
    () => StratumProvider(
      onBlockFound: (block) => GetIt.I.get<NotificationProvider>().add(
        id: 'stratum-block-${block.hash}',
        title: 'Block ${block.height} found',
        content: '${block.worker} found it. The reward is spendable after 100 blocks.',
        dialogType: DialogType.success,
      ),
    )..startPolling(),
  );
  putScoped<HDWalletProvider>(() => HDWalletProvider());
  putScoped<MempoolWatchProvider>(() => MempoolWatchProvider());
  putScoped<MiningPoolsProvider>(() => MiningPoolsProvider());
  put<BitDriveProvider>(() => BitDriveProvider());
  // Eager initialization so it can listen for wallet unlock events
  putScoped<CheckProvider>(() => CheckProvider());
  putScoped<PsbtDraftProvider>(() => PsbtDraftProvider());
  put<TimestampProvider>(() => TimestampProvider());
  final bitwindowHomepageProvider = BitwindowHomepageProvider();
  GetIt.I.registerLazySingleton<BitwindowHomepageProvider>(() => bitwindowHomepageProvider);
  GetIt.I.registerLazySingleton<HomepageProvider>(() => bitwindowHomepageProvider);
  GetIt.I.registerLazySingleton<MempoolProvider>(() => MempoolProvider());
  put<NotificationStreamProvider>(() => NotificationStreamProvider());
  putScoped<ForkProvider>(() => ForkProvider()..init());
  put<BackendSwapProvider>(() => BackendSwapProvider());
  put<ECashMigrationProvider>(() => ECashMigrationProvider()..start());
  put<ChatProvider>(() => ChatProvider());
  putScoped<FastWithdrawalProvider>(() => FastWithdrawalProvider());
  put<UpdateProvider>(
    () => UpdateProvider(
      log: log,
      binaryType: BinaryType.BINARY_TYPE_BITWINDOWD,
      currentVersion: AppVersion.version,
      onBeforeUpdate: isSubWindow
          ? null
          : () async {
              final binaryProvider = GetIt.I.get<BinaryProvider>();
              await binaryProvider.onShutdown();
            },
    ),
  );

  return (applicationDir, logFile, log);
}

/// Refetches the block-driven providers that this window built.
void refetchBuiltOnNewBlock() {
  if (GetIt.I.checkLazySingletonInstanceExists<BalanceProvider>()) {
    unawaited(GetIt.I<BalanceProvider>().fetch());
  }
  if (GetIt.I.checkLazySingletonInstanceExists<BlockchainProvider>()) {
    unawaited(GetIt.I<BlockchainProvider>().fetch());
  }
  if (GetIt.I.checkLazySingletonInstanceExists<TransactionProvider>()) {
    unawaited(GetIt.I<TransactionProvider>().fetch());
  }
}

/// Refetches the providers that this window built at an earlier page and that do not poll.
void refetchBuiltOnOpen() {
  if (GetIt.I.checkLazySingletonInstanceExists<AddressBookProvider>()) {
    unawaited(GetIt.I<AddressBookProvider>().fetch());
  }
}

Future<void> runMainWindow(Logger log, Directory applicationDir, File logFile) async {
  // bitwindowd's output already reaches the console. drivechaind runs
  // detached and writes to the shared file, so a terminal launch shows nothing
  // of the daemon that starts every other one.
  if (!orchestratorLogsToStdout(Platform.environment)) {
    await SharedLogTail(file: logFile, source: 'orchestrator', onLine: debugPrint).start();
  }

  final snapshot = _rootSnapshot;
  final backendState = GetIt.I.get<BackendStateProvider>();
  final showRoot = ValueNotifier<bool>(snapshot != null);
  if (snapshot != null) {
    log.i('STARTUP: showing the root page with the state of the last session');
    backendState.starting = true;
  }
  BootSnapshotWriter(
    appDir: applicationDir,
    conf: GetIt.I.get<BitcoinConfProvider>(),
    nodeMode: GetIt.I.get<NodeModeProvider>(),
    walletReader: GetIt.I.get<WalletReaderProvider>(),
    log: log,
    written: snapshot?.encode(),
  ).start();

  final firstFrame = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) => firstFrame.complete());
  final boot = () async {
    try {
      await bootBitwindowBackend(log, rootShown: snapshot != null, firstFrame: firstFrame.future);
    } catch (e) {
      log.e('bootBitwindowBackend failed: $e');
      if (backendState.starting) {
        backendState.startWatching();
      }
    } finally {
      log.i('STARTUP: showing BitWindow UI');
      // Show the app even if boot failed — providers will reconnect.
      showRoot.value = true;
    }
  }();
  unawaited(
    boot.then((_) => SchedulerBinding.instance.scheduleTask(GetIt.I.get<WindowProvider>().startSpare, Priority.idle)),
  );

  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Bitcoin Core + CUSF BIP 300/301 Enforcer',
  );

  final look = SailAppLook.load();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await setupSignalHandlers(log);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // check for updates on boot and every hour therafter
    unawaited(initAutoUpdater(log));
  });

  GetIt.I.registerSingleton<HostedChains>(
    HostedChains(
      binaries: GetIt.I.get<BinaryProvider>(),
      modules: hostedModules,
      applicationDir: applicationDir,
      log: log,
      navigatorFor: (module) => HostChainNavigator(module.chain),
    ),
  );

  final claimsTruthcoinLinks = !GetIt.I.get<SettingsProvider>().bitwindowSettings.openSidechainsInWindow;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    startTruthcoinLinks(log, claimScheme: claimsTruthcoinLinks);
  });

  return runApp(BitwindowApp(log: log, showRoot: showRoot, look: await look));
}

void runMultiWindow(String argumentsStr, Logger log, Directory applicationDir, File logFile) async {
  final arguments = jsonDecode(argumentsStr) as Map<String, dynamic>;
  final windowTitle = arguments['window_title'] as String?;
  final windowX = arguments['window_x'] as double? ?? 100;
  final windowY = arguments['window_y'] as double? ?? 100;
  final windowWidth = arguments['window_width'] as double? ?? 800;
  final windowHeight = arguments['window_height'] as double? ?? 600;

  if (windowTitle == null) {
    throw ArgumentError('Missing required arguments for multi-window mode: window_title');
  }

  // window_manager acts on the main window of the process, not on this one.
  final windowController = await WindowController.fromCurrentEngine();
  await windowController.setFrame(Rect.fromLTWH(windowX, windowY, windowWidth, windowHeight));
  await windowController.setTitle(windowTitle);
  await windowController.show();

  final page = subWindowPage(arguments, logFile, {});

  unawaited(
    WidgetsBinding.instance.waitUntilFirstFrameRasterized.then(
      (_) => GetIt.I.get<WindowProvider>().sendMessageToMain(windowShownMethod, null),
    ),
  );
  return runApp(buildSailWindowApp(log, page.title, page.child, _subWindowAccent));
}

const _subWindowAccent = Color.fromARGB(255, 255, 153, 0);

/// The page of a sub-window for [arguments]. A logs page copies the process
/// output from [logCursors] on.
({String title, Widget child, Timer? work}) subWindowPage(
  Map<String, dynamic> arguments,
  File logFile,
  Map<int, int> logCursors,
) {
  final windowType = arguments['window_type'] as String?;
  final windowTitle = arguments['window_title'] as String;
  Timer? work;
  Widget child = SailCard(
    title: 'Unknown window type: $windowType',
    child: SailText.primary15('Programmers messed up, and supplied an unknown window type: $windowType'),
  );

  // Map string identifiers to window types
  switch (windowType) {
    case SubWindowTypes.debugId:
      child = DebugWindow();
      break;

    case SubWindowTypes.logsId:
      final logWindow = LogWindowArguments.fromWindowArguments(arguments, bitwindowLogPath: logFile.path);
      work = ProcessLogRelay(
        GetIt.I.get<WindowProvider>(),
        GetIt.I.get<LogProvider>(),
        only: logWindow.binaryType,
        cursors: logCursors,
      ).start();
      child = LogPage(logPath: logWindow.logPath, title: logWindow.title, binaryType: logWindow.binaryType);
      break;

    case SubWindowTypes.deniabilityId:
      child = DeniabilityTab(newWindowButton: null);
      break;

    case SubWindowTypes.blockExplorerId:
      child = const BlockExplorerDialog();
      break;

    case SubWindowTypes.addressbookId:
      child = AddressBookTable();
      break;

    case SubWindowTypes.messageSignerId:
      child = const MessageSigner();
      break;

    case SubWindowTypes.hashCalculatorId:
      child = const HashCalculator();
      break;
    case SubWindowTypes.converterId:
      child = const ConverterWindow();
      break;
    case SubWindowTypes.hdWalletId:
      child = const HDWalletTab();
      break;
    case SubWindowTypes.multisigLoungeId:
      child = const MultisigLoungeTab();
      break;
    case SubWindowTypes.bitDriveId:
      child = const BitDriveTab();
      break;
  }

  return (title: '$windowTitle | Bitwindow', child: child, work: work);
}

void ignoreOverflowErrors(FlutterErrorDetails details, {bool forceReport = false}) {
  bool ifIsOverflowError = false;

  // Detect overflow error.
  var exception = details.exception;
  if (exception is FlutterError) {
    ifIsOverflowError = !exception.diagnostics.any((e) => e.value.toString().startsWith('A RenderFlex overflowed by'));
  }

  // Ignore if is overflow error.
  if (ifIsOverflowError) {
    debugPrint('ignored overflow error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}

Future<File> getLogFile() async {
  final datadir = await Environment.datadir();
  return prepareLogFile(datadir, sharedLogFileName);
}

class BitwindowApp extends StatefulWidget {
  final Logger log;
  final ValueNotifier<bool> showRoot;
  final SailAppLook? look;

  const BitwindowApp({super.key, required this.log, required this.showRoot, this.look});

  @override
  State<BitwindowApp> createState() => _BitwindowAppState();
}

class _BitwindowAppState extends State<BitwindowApp> {
  late BitcoinConfProvider _bitcoinConfProvider;
  BitcoinNetwork? _currentNetwork;

  @override
  void initState() {
    super.initState();
    _bitcoinConfProvider = GetIt.I.get<BitcoinConfProvider>();
    _currentNetwork = _bitcoinConfProvider.network;
    _bitcoinConfProvider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _bitcoinConfProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    final newNetwork = _bitcoinConfProvider.network;
    if (newNetwork != _currentNetwork) {
      _currentNetwork = newNetwork;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = GetIt.I.get<AppRouter>();
    final accentColor = getNetworkAccentColor(_bitcoinConfProvider.network);

    return SailApp(
      log: widget.log,
      dense: true,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.showRoot,
          builder: (context, ready, _) {
            if (!ready) {
              return const _SplashScreen();
            }
            return _BitwindowAppContent(router: router);
          },
        );
      },
      accentColor: accentColor,
      look: widget.look,
    );
  }
}

class _BitwindowAppContent extends StatelessWidget {
  final AppRouter router;

  const _BitwindowAppContent({required this.router});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: 'Bitcoin Core + CUSF BIP 300/301 Enforcer',
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        fontFamily: theme.chrome.textFamily(monospace: font == SailFontValues.ibmMono),
        scaffoldBackgroundColor: theme.colors.background,
      ),
      builder: (context, child) {
        // PersistentStatusBar collapses to SizedBox.shrink when orch +
        // bitwindowd are healthy (or still booting), so this wrap adds no
        // layout cost on normal routes. When either daemon fails terminally
        // it renders a 36px red banner — visible on pre-auth screens where
        // root_page's richer BottomNav isn't mounted.
        return _ErrorBoundary(
          child: Scaffold(
            body: child ?? const SizedBox.shrink(),
            bottomNavigationBar: const BackendSwapBar(child: PersistentStatusBar()),
          ),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: theme.colors.background),
      home: QtPage(
        child: Stack(
          children: [
            Center(child: SailSVG.fromAsset(SailSVGAsset.layerTwoLabsLogo, height: 71)),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: SailColumn(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const BackendSwapSplash(),
                    const SizedBox(
                      width: 200,
                      child: ProgressBar(current: 0, goal: 1, hideProgressInside: true, small: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBoundary extends StatefulWidget {
  final Widget child;

  const _ErrorBoundary({required this.child});

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  @override
  void initState() {
    super.initState();
    // Framework errors (build / layout / paint / scheduler callbacks) are
    // reported here. Most are localized and recoverable — a single stray
    // assertion in one widget (e.g. a log autoscroll racing a detached
    // ScrollController) must NOT tear down the whole app behind a full-screen
    // crash page. So we log and continue, matching Flutter's default
    // resilience. Genuinely fatal paths are still covered: boot failures by
    // runErrorScreen() in main(), build failures by ErrorWidget.builder below.
    FlutterError.onError = (FlutterErrorDetails details) {
      final isOverflowError =
          details.exception is FlutterError &&
          (details.exception as FlutterError).diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
        debugPrint('Overflow error detected, continuing normally');
        return;
      }
      FlutterError.dumpErrorToConsole(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    return _ErrorCatcher(child: widget.child);
  }
}

class _ErrorCatcher extends StatelessWidget {
  final Widget child;

  const _ErrorCatcher({required this.child});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Render the failure INLINE, at the failing widget's location in the
      // tree, so only that component breaks instead of the whole window.
      // Ancestor-independent on purpose (its own Directionality, no
      // MaterialApp/Scaffold) so it renders even when the failure site lacks
      // those ancestors. Only catches build/layout/paint errors — runtime and
      // async errors go through FlutterError.onError (log & continue).
      FlutterError.presentError(details);
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF2A2A2A),
          child: Text(
            '⚠ Failed to render this component\n${details.exceptionAsString()}',
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      );
    };
    return child;
  }
}

/// How long the boot waits for drivechaind. A fresh bitwindowd first retires
/// the drivechaind of the last session, and one that predates the keep_l1
/// field drains bitcoind before it goes. A short wait would end the boot
/// before that daemon frees the port, and the L1 stack would stay down.
const drivechaindReadyTimeout = Duration(seconds: 150);

/// The time between two drivechaind readiness probes. The UI waits for the
/// first answer, so a long gap delays the boot.
const drivechaindReadyPoll = Duration(milliseconds: 25);

/// Calls [probe] until it returns without an error. Returns false when
/// [timeout] ends first.
Future<bool> waitForDrivechaind(
  Future<void> Function() probe, {
  Duration every = drivechaindReadyPoll,
  Duration timeout = drivechaindReadyTimeout,
}) async {
  final elapsed = Stopwatch()..start();
  for (var waited = Duration.zero; ; waited += every) {
    try {
      await probe();
      return true;
    } catch (_) {
      // [waited] counts the polls, so a test with a fake clock ends too.
      if (waited >= timeout || elapsed.elapsed >= timeout) {
        return false;
      }
      await Future.delayed(every);
    }
  }
}

/// [rootShown] is true when the root page showed before the backend answered.
/// The readiness reads wait for [firstFrame], so their replies do not hold it back.
Future<void> bootBitwindowBackend(Logger log, {bool rootShown = false, Future<void>? firstFrame}) async {
  log.i('STARTUP: Booting BitWindow backend');

  final binaryProvider = GetIt.I.get<BinaryProvider>();
  final orchestrator = GetIt.I.get<OrchestratorRPC>();
  final backendState = GetIt.I.get<BackendStateProvider>();
  // Download grpcurl in background (needed for enforcer-cli in console)
  final grpcurl = binaryProvider.binaries.firstWhere((b) => b is GRPCurl);
  unawaited(() async {
    try {
      log.i('Downloading grpcurl in background');
      await binaryProvider.download(grpcurl, shouldUpdate: true);
      log.i('grpcurl download complete');
    } catch (e) {
      log.w('Failed to download grpcurl: $e');
    }
  }());

  // 1. Start bitwindowd — it manages drivechaind internally,
  //    which in turn manages bitcoind, enforcer, and sidechains.
  final localAuthFlag = Platform.environment['ORCHESTRATOR_LOCAL_AUTH']?.toLowerCase();
  final localAuth = localAuthFlag != 'false' && localAuthFlag != '0';
  log.i('STARTUP: starting bitwindowd');
  await startBitwindowd(binaryProvider, swap: GetIt.I.get<BackendSwapProvider>());
  await firstFrame;

  // 1b. Local auth is on by default; the kill switch is ORCHESTRATOR_LOCAL_AUTH
  //     =false/0 on our env, which we pass down to the backend. When on, the
  //     backend writes a per-session cookie a moment after spawn — load it into
  //     memory before the readiness RPCs below, which now require it. Same
  //     await-on-startup pattern as the readiness loop. Skipped when disabled so
  //     we don't wait for a cookie that will never appear.
  if (localAuth) {
    log.i('STARTUP: waiting for local auth cookie');
    final loaded = await LocalAuth.load();
    log.i(loaded ? 'STARTUP: local auth cookie loaded' : 'STARTUP: local auth cookie did not appear');
  }

  // 2. Wait for drivechaind (managed by bitwindowd) to become ready.
  //    _startDaemonBinary cleared bitwindow's initializingBinary when the
  //    process came up, but we're not actually "ready" until drivechaind
  //    is serving gRPC — re-assert the flag and push a startup log so
  //    DaemonConnectionCard keeps the spinner + status message during the
  //    wait rather than flashing "Not connected".
  log.i('STARTUP: waiting for drivechaind readiness');
  final bitwindowRpc = GetIt.I.isRegistered<BitwindowRPC>() ? GetIt.I.get<BitwindowRPC>() : null;
  if (bitwindowRpc != null) {
    bitwindowRpc.initializingBinary = true;
    bitwindowRpc.connectionError = null;
    bitwindowRpc.markStateChanged();
  }
  binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_DRIVECHAIND, 'Waiting for drivechaind...');
  binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_BITWINDOWD, 'Waiting for drivechaind...');

  final orchestratorReady = await waitForDrivechaind(() async {
    await orchestrator.listBinaries();
    // Backend is up now; load the real network before the UI shows so it
    // never renders the default one.
    await GetIt.I.get<BitcoinConfProvider>().loadConfig();
  });
  if (orchestratorReady) {
    log.i('STARTUP: drivechaind is ready');
    // SettingsProvider.create ran before drivechaind was up, so the
    // test-sidechains flag may still be the cached/default value. Pull
    // the real one from drivechaind now — BinaryProvider listens to
    // SettingsProvider and re-fetches binary release timestamps with
    // the right (test vs prod) URL when this flips.
    if (bitwindowRpc != null) {
      bitwindowRpc.initializingBinary = false;
      bitwindowRpc.markStateChanged();
    }
  } else {
    log.e('STARTUP: drivechaind did not become ready after ${drivechaindReadyTimeout.inSeconds}s');
  }
  // If the wait exhausted without success, leave initializingBinary alone —
  // let the error state surface naturally via backendState.startWatching().
  if (!orchestratorReady) {
    log.w('STARTUP: proceeding without drivechaind readiness confirmation');
  }

  // 3. Now that drivechaind is up, re-seed the wallet reader. The
  //    earlier init() in setupBitwindow runs before any backend exists, so
  //    its listWallets/getWalletStatus calls fail and the provider sits
  //    empty until the WatchWalletData stream eventually delivers — which
  //    can lag long enough that the wallet dropdown, BIP47 card and
  //    starters tab render empty against an already-loaded wallet.
  if (orchestratorReady && GetIt.I.isRegistered<WalletReaderProvider>()) {
    await GetIt.I.get<WalletReaderProvider>().init();
  }
  // The password guard let the root page of the last session through.
  if (orchestratorReady && rootShown) {
    unawaited(_unlockIfLocked(orchestrator, log));
  }

  await startBackendsForMode(
    orchestrator: orchestrator,
    backendState: backendState,
    orchestratorReady: orchestratorReady,
    log: log,
  );

  await _daemonWarmUp.done();
  log.i('STARTUP: BitWindow backend boot task initialized');
}

/// How long a failed first boot mode write waits before the next try.
const firstBootModeRetry = Duration(seconds: 5);

/// Starts the log streams and the state watch, then reads the node mode and
/// starts the backends it needs. The watch runs even when the mode read fails.
Future<void> startBackendsForMode({
  required OrchestratorRPC orchestrator,
  required BackendStateProvider backendState,
  required bool orchestratorReady,
  required Logger log,
  Duration retryEvery = firstBootModeRetry,
}) async {
  streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);
  streamBinaryLogs(orchestrator, 'enforcer', BinaryType.BINARY_TYPE_ENFORCER, log);

  log.i('STARTUP: starting backend state watch');
  backendState.startWatching();

  if (orchestratorReady) {
    await _bootForMode(orchestrator: orchestrator, orchestratorReady: true, log: log, retryEvery: retryEvery);
    return;
  }

  // drivechaind came up after the readiness wait, so the state watch is what
  // sees it answer. The boot then runs once.
  void onBackendState() {
    if (!backendState.orchestratorAnswered || !backendState.orchestratorReachable) {
      return;
    }
    backendState.removeListener(onBackendState);
    log.i('STARTUP: drivechaind answered after the readiness wait');
    unawaited(_bootForMode(orchestrator: orchestrator, orchestratorReady: true, log: log, retryEvery: retryEvery));
    unawaited(_unlockIfLocked(orchestrator, log));
  }

  backendState.addListener(onBackendState);
  onBackendState();
}

/// Reads the node mode again and records it like a cold boot when none is
/// recorded, then starts the backends that mode needs.
Future<void> reconcileNodeMode({
  required OrchestratorRPC orchestrator,
  required Logger log,
  Duration retryEvery = firstBootModeRetry,
}) => _bootForMode(orchestrator: orchestrator, orchestratorReady: true, log: log, retryEvery: retryEvery);

// The password guard ran while drivechaind was down, and read no encryption.
Future<void> _unlockIfLocked(OrchestratorRPC orchestrator, Logger log) async {
  final wmpb.GetWalletStatusResponse status;
  try {
    status = await orchestrator.wallet.getWalletStatus();
  } catch (e) {
    log.e('STARTUP: could not read the wallet lock after a late drivechaind: $e');
    return;
  }
  if (status.state != wmpb.WalletState.WALLET_STATE_LOCKED) {
    return;
  }
  log.i('STARTUP: the wallet is locked, asking for its password');
  await GetIt.I.get<AppRouter>().push(sail_routes.UnlockWalletRoute());
}

Future<void> _bootForMode({
  required OrchestratorRPC orchestrator,
  required bool orchestratorReady,
  required Logger log,
  required Duration retryEvery,
}) async {
  final BackendBoot boot;
  try {
    boot = await readBackendBoot(
      orchestratorReady: orchestratorReady,
      // A status that does not arrive must not read as an empty install.
      hasWallet: () async =>
          (await orchestrator.wallet.getWalletStatus()).state != wmpb.WalletState.WALLET_STATE_NO_WALLET,
    );
    if (orchestratorReady && !GetIt.I.get<NodeModeProvider>().loaded) {
      throw StateError('the backend did not answer the node mode read');
    }
  } catch (e) {
    log.e('STARTUP: could not record the node mode, trying again in ${retryEvery.inSeconds}s: $e');
    GetIt.I.get<NotificationProvider>().add(
      id: 'first-boot-node-mode',
      title: 'Could not switch',
      content: '$e',
      dialogType: DialogType.error,
    );
    unawaited(
      Future.delayed(
        retryEvery,
        () => _bootForMode(
          orchestrator: orchestrator,
          orchestratorReady: orchestratorReady,
          log: log,
          retryEvery: retryEvery,
        ),
      ),
    );
    return;
  }

  // StartWithL1 returns at once and adopts a draining drivechaind of an earlier bitwindowd.
  if (orchestratorReady && boot.startsBackends) {
    unawaited(() async {
      try {
        await orchestrator.startWithL1('enforcer');
      } catch (e) {
        log.w('STARTUP: L1 stack dispatch failed (non-fatal): $e');
      }
    }());
  } else if (orchestratorReady) {
    log.i('STARTUP: ${boot.reason}');
  }
}

/// The binaries whose log stream runs. A second boot must not add a second
/// stream, because every stream writes the same lines to the log page.
final Set<String> _streamedBinaries = {};

/// Starts the log stream of [binaryName], one per binary and app.
@visibleForTesting
void streamBinaryLogs(OrchestratorRPC orchestrator, String binaryName, BinaryType binaryType, Logger log) {
  if (!_streamedBinaries.add(binaryName)) {
    return;
  }
  _watchBinaryLogs(orchestrator, binaryName, binaryType, log);
}

/// The binaries with a reconnect in flight. An error and a close both end one
/// stream, so without this the retry would open two.
final Set<String> _reopenPending = {};

@visibleForTesting
void forgetBinaryLogStreams() {
  _streamedBinaries.clear();
  _reopenPending.clear();
}

void _watchBinaryLogs(
  OrchestratorRPC orchestrator,
  String binaryName,
  BinaryType binaryType,
  Logger log, {
  StreamLogsResponse? cursor,
}) {
  final logProvider = GetIt.I.get<LogProvider>();

  orchestrator
      .streamLogs(binaryName, tail: 100, runId: cursor?.runId ?? '', afterSequence: cursor?.sequence)
      .listen(
        (response) {
          cursor = response;
          logProvider.addLog(
            FullProcessLogEntry(
              timestamp: DateTime.fromMillisecondsSinceEpoch(response.timestampUnix.toInt() * 1000),
              message: response.line,
              isStderr: response.stream == 'stderr',
              binaryType: binaryType,
            ),
          );
        },
        onError: (e) => _reopenBinaryLogs(orchestrator, binaryName, binaryType, log, cursor),
        onDone: () => _reopenBinaryLogs(orchestrator, binaryName, binaryType, log, cursor),
        cancelOnError: true,
      );
}

/// The backend ends the stream on a reboot, by an error or by a plain close.
/// The log page goes silent until this opens the one stream again.
void _reopenBinaryLogs(
  OrchestratorRPC orchestrator,
  String binaryName,
  BinaryType binaryType,
  Logger log,
  StreamLogsResponse? cursor,
) {
  if (!_reopenPending.add(binaryName)) {
    return;
  }
  Future.delayed(const Duration(seconds: 5), () {
    _reopenPending.remove(binaryName);
    _watchBinaryLogs(orchestrator, binaryName, binaryType, log, cursor: cursor);
  });
}

Future<void> rebootBitwindowBackend(Logger log) async {
  final binaryProvider = GetIt.I.get<BinaryProvider>();
  final swap = GetIt.I.get<BackendSwapProvider>();

  try {
    swap.report(BackendSwapStep.stop);
    // Ask first, kill second: bitwindowd relays this on a clean exit, but it gets
    // force-killed if it lingers, and then nothing would drain drivechaind.
    try {
      await GetIt.I.get<OrchestratorRPC>().shutdown();
    } catch (e) {
      log.w('REBOOT: drivechaind shutdown call failed: $e');
    }
    await binaryProvider.stop(BitWindow());
    await _awaitDrivechaindExit(log);
    swap.report(BackendSwapStep.start);
    await bootBitwindowBackend(log);
    swap.finish();
  } catch (e) {
    swap.fail(e);
    rethrow;
  }
}

/// Blocks until drivechaind's port stops accepting, the same signal bitwindowd
/// uses to choose between adopting a live daemon and spawning one.
Future<void> _awaitDrivechaindExit(Logger log) async {
  final host = Environment.orchestratorHost.value;
  final port = Environment.orchestratorPort.value;
  final deadline = DateTime.now().add(const Duration(seconds: 150));

  while (DateTime.now().isBefore(deadline)) {
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 2));
      socket.destroy();
    } catch (_) {
      log.i('REBOOT: drivechaind released $host:$port');
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }
  // Booting now would adopt the daemon we meant to replace.
  throw StateError('drivechaind is still holding $host:$port — restart BitWindow to finish');
}

// Restores a wallet from a backup file (.zip/.json). The backend RestoreBackup
// RPC writes the wallet and reboots the L1 stack so the enforcer picks it up —
// the frontend just hands over the file.
Future<void> restoreBitwindowWalletFromFile(File backupFile) async {
  final walletApi = GetIt.I.get<BitwindowRPC>().wallet;
  final bytes = await backupFile.readAsBytes();
  final filename = backupFile.uri.pathSegments.last;

  final validation = await walletApi.validateBackup(bytes, filename);
  if (!validation.valid) {
    throw Exception(validation.errorMessage.isNotEmpty ? validation.errorMessage : 'Invalid backup file');
  }
  await walletApi.restoreBackup(bytes, filename);
}

Future<void> setupSignalHandlers(Logger log) async {
  // SIGINT and SIGTERM are not properly supported on Windows
  if (Platform.isWindows) {
    return;
  }

  ProcessSignal.sigint.watch().listen((signal) async {
    log.i('Received SIGINT, shutting down...');
    await GetIt.I.get<BinaryProvider>().onShutdown();
    exit(0);
  });

  ProcessSignal.sigterm.watch().listen((signal) async {
    log.i('Received SIGTERM, shutting down...');
    await GetIt.I.get<BinaryProvider>().onShutdown();
    exit(0);
  });
}

// BitWindow window types
class SubWindowTypes {
  static const String debugId = 'debug';
  static var debug = SailWindow(
    identifier: debugId,
    name: 'Debug',
    defaultSize: Size(800, 600),
    defaultPosition: Offset(100, 100),
  );

  static const String logsId = 'logs';
  static var logs = SailWindow(
    identifier: logsId,
    name: 'Logs',
    defaultSize: Size(800, 600),
    defaultPosition: Offset(100, 100),
  );

  static SailWindow logsFor(String title) =>
      SailWindow(identifier: logsId, name: title, defaultSize: logs.defaultSize, defaultPosition: logs.defaultPosition);

  static const String deniabilityId = 'deniability';
  static var deniability = SailWindow(
    identifier: deniabilityId,
    name: 'Deniability',
    defaultSize: Size(600, 400),
    defaultPosition: Offset(200, 200),
  );

  static const String blockExplorerId = 'block_explorer';
  static var blockExplorer = SailWindow(
    identifier: blockExplorerId,
    name: 'Block Explorer',
    defaultSize: Size(1000, 700),
    defaultPosition: Offset(150, 150),
  );

  static const String addressbookId = 'addressbook';
  static var addressbook = SailWindow(
    identifier: addressbookId,
    name: 'Address Book',
    defaultSize: Size(1000, 700),
    defaultPosition: Offset(150, 150),
  );

  static const String messageSignerId = 'message_signer';
  static var messageSigner = SailWindow(
    identifier: messageSignerId,
    name: 'Message Signer',
    defaultSize: Size(800, 600),
    defaultPosition: Offset(150, 150),
  );

  static const String hashCalculatorId = 'hash_calculator';
  static var hashCalculator = SailWindow(
    identifier: hashCalculatorId,
    name: 'Hash Calculator',
    // set width to half of screen size, full height
    defaultSize: Size(double.maxFinite / 2, double.maxFinite),
    defaultPosition: Offset(double.maxFinite / 2, 0),
  );

  static const String converterId = 'converter';
  static var converter = SailWindow(
    identifier: converterId,
    name: 'Converter',
    defaultSize: Size(1000, 800),
    defaultPosition: Offset(120, 120),
  );

  static const String hdWalletId = 'hd_wallet';
  static var hdWallet = SailWindow(
    identifier: hdWalletId,
    name: 'HD Wallet Explorer',
    defaultSize: Size(1200, 800),
    defaultPosition: Offset(100, 100),
  );

  static const String multisigLoungeId = 'multisig_lounge';
  static var multisigLounge = SailWindow(
    identifier: multisigLoungeId,
    name: 'Multisig Lounge',
    defaultSize: Size(1200, 800),
    defaultPosition: Offset(100, 100),
  );

  static const String bitDriveId = 'bitdrive';
  static var bitDrive = SailWindow(
    identifier: bitDriveId,
    name: 'BitDrive',
    defaultSize: Size(1000, 700),
    defaultPosition: Offset(150, 150),
  );
}

List<Binary> initalBinaries() {
  return [...coreBinaries, ...sidechainBinaries, resolveFromConfig(BinaryType.BINARY_TYPE_GRPCURL, () => GRPCurl())];
}

Future<void> initAutoUpdater(Logger log) async {
  if (!Platform.isMacOS && !Platform.isWindows) {
    log.i('Skipping auto updater initialization because we are not on macOS or Windows)');
    return;
  }

  try {
    // Variant builds self-update from their own feed so they don't cross-update
    // to the standard BitWindow release.
    const feedURL = String.fromEnvironment(
      'BITWINDOW_APPCAST_URL',
      defaultValue: 'https://releases.drivechain.info/appcast-bitwindow.xml',
    );
    log.i('Initializing auto updater with feed URL: $feedURL');

    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates(inBackground: true);

    log.i('Auto updater initialized successfully');
  } catch (e) {
    log.w('Failed to initialize auto updater: $e');
  }
}
