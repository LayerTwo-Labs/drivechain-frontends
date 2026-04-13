import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:auto_updater/auto_updater.dart';
import 'package:bitassets/config/runtime_args.dart';
import 'package:bitassets/gen/version.dart';
import 'package:bitassets/providers/bitassets_conf_provider.dart';
import 'package:bitassets/providers/bitassets_homepage_provider.dart';
import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/providers/favorites_provider.dart';
import 'package:bitassets/providers/price_alert_provider.dart';
import 'package:bitassets/routing/router.dart';
import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/backend_sidechain_runtime.dart';
import 'package:sail_ui/config/fonts.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';

bool _signalShutdownInProgress = false;
AppLifecycleListener? _appLifecycleListener;

void main(List<String> args) async {
  await withWindowsFileRetry(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Get the current window controller to check if this is a sub-window
      final windowController = await WindowController.fromCurrentEngine();

      final (applicationDir, logFile, log) = await init(windowController.arguments);

      // If arguments are not empty, this is a sub-window
      if (windowController.arguments.isNotEmpty) {
        return runMultiWindow(windowController.arguments, log, applicationDir, logFile);
      }

      await runMainWindow(log, applicationDir, logFile);
    } catch (e, stackTrace) {
      runErrorScreen(e, stackTrace);
    }
  });
}

Future<(Directory, File, Logger)> init(String arguments) async {
  addFontLicense();

  Directory? applicationDir;
  File? logFile;

  // If arguments are not empty, parse them for sub-window mode
  if (arguments.isNotEmpty) {
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
  applicationDir ??= await RuntimeArgs.datadir();
  logFile ??= await getLogFile(applicationDir);

  final log = await logger(RuntimeArgs.fileLog, RuntimeArgs.consoleLog, logFile);
  GetIt.I.registerLazySingleton<Logger>(() => log);
  final router = AppRouter();
  GetIt.I.registerLazySingleton<AppRouter>(() => router);

  late BitAssetsLive bitassetsRPC;

  await initSidechainDependencies(
    sidechainType: BinaryType.bitassets,
    createSidechainConnection: (_) {
      bitassetsRPC = BitAssetsLive();
      GetIt.I.registerSingleton<BitAssetsRPC>(bitassetsRPC);
      return bitassetsRPC;
    },
    applicationDir: applicationDir,
    log: log,
    router: router,
    currentVersion: AppVersion.version,
    additionalBinaries: () => [Orchestratord()],
  );

  // Register shared orchestrator runtime and start the managed backend.
  unawaited(
    initBackendManagedSidechainRuntime(
      log: log,
      binary: BinaryType.bitassets,
    ),
  );

  // Initialize BitassetsConfProvider (must be after BitcoinConfProvider)
  final bitassetsConfProvider = await BitassetsConfProvider.create();
  GetIt.I.registerLazySingleton<GenericSidechainConfProvider>(() => bitassetsConfProvider);

  GetIt.I.registerLazySingleton<BitAssetsProvider>(
    () => BitAssetsProvider(),
  );

  // Register asset analytics provider
  GetIt.I.registerLazySingleton<AssetAnalyticsProvider>(
    () => AssetAnalyticsProvider(),
  );

  // Register favorites provider
  GetIt.I.registerLazySingleton<FavoritesProvider>(
    () => FavoritesProvider(),
  );

  // Register price alert provider
  GetIt.I.registerLazySingleton<PriceAlertProvider>(
    () => PriceAlertProvider(),
  );

  // Register homepage provider
  final bitassetsHomepageProvider = BitAssetsHomepageProvider();
  GetIt.I.registerLazySingleton<BitAssetsHomepageProvider>(() => bitassetsHomepageProvider);
  GetIt.I.registerLazySingleton<HomepageProvider>(() => bitassetsHomepageProvider);

  return (applicationDir, logFile, log);
}

void bootBinaries(Logger log) {
  unawaited(
    bootBackendManagedSidechain(
      log: log,
      binary: BinaryType.bitassets,
    ),
  );
}

Future<void> runMultiWindow(String argumentsStr, Logger log, Directory applicationDir, File logFile) async {
  final arguments = jsonDecode(argumentsStr) as Map<String, dynamic>;
  log.i('starting bitassets');
  final bitassets = GetIt.I.get<BitAssetsRPC>();

  Widget child = SailCard(
    child: SailText.primary15('no window type provided, the programmers messed up'),
  );

  switch (arguments['window_type']) {
    case SubWindowTypes.debugId:
      child = SidechainDebugWindow(
        rpc: bitassets,
        sidechainName: 'BitAssets',
      );
      break;
    case SubWindowTypes.logsId:
      child = LogPage(
        logPath: logFile.path,
        title: 'Bitassets Logs',
      );
      break;
  }

  return runApp(
    buildSailWindowApp(
      log,
      '${arguments['window_title'] as String} | BitAssets',
      child,
      bitassets.chain.color,
    ),
  );
}

Future<void> runMainWindow(Logger log, Directory applicationDir, File logFile) async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'BitAssets Sidechain',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  // Initialize WindowProvider for the main window
  final windowProvider = await WindowProvider.newInstance(logFile, applicationDir, isMainWindow: true);
  GetIt.I.registerLazySingleton<WindowProvider>(() => windowProvider);

  _installSignalShutdownHandlers(log);
  _installAppExitHandler(log);

  await initAutoUpdater(log);

  log.i('starting bitassets');
  final bitassets = GetIt.I.get<BitAssetsRPC>();
  final router = GetIt.I.get<AppRouter>();
  runApp(
    SailApp(
      dense: false,
      builder: (context) {
        return _BitAssetsAppContent(
          router: router,
          bitassets: bitassets,
        );
      },
      accentColor: bitassets.chain.color,
      log: log,
    ),
  );
}

class _BitAssetsAppContent extends StatelessWidget {
  final AppRouter router;
  final BitAssetsRPC bitassets;

  const _BitAssetsAppContent({
    required this.router,
    required this.bitassets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: bitassets.chain.name,
      theme: ThemeData(
        fontFamily: font == SailFontValues.ibmMono ? 'IBMPlexMono' : 'Inter',
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: bitassets.chain.color),
      ),
    );
  }
}

bool isCurrentChainActive({
  required List<ActiveSidechain> activeChains,
  required Binary currentChain,
}) {
  final foundMatch = activeChains.firstWhereOrNull((chain) => chain.title == currentChain.name);
  return foundMatch != null;
}

Future<File> getLogFile(Directory datadir) async {
  try {
    await datadir.create(recursive: true);
  } catch (error) {
    debugPrint('Failed to create datadir: $error');
  }

  final path = [datadir.path, 'debug.log'].join(Platform.pathSeparator);
  final logFile = File(path);

  return logFile;
}

void _installSignalShutdownHandlers(Logger log) {
  if (Platform.isWindows) {
    return;
  }

  Future<void> handleSignal(ProcessSignal signal) async {
    if (_signalShutdownInProgress) {
      return;
    }

    _signalShutdownInProgress = true;
    log.w('received ${signal.toString()}, shutting down BitAssets runtime');

    try {
      if (GetIt.I.isRegistered<BinaryProvider>()) {
        await GetIt.I.get<BinaryProvider>().onShutdown();
      }
    } catch (error, stackTrace) {
      log.e('signal shutdown failed: $error\n$stackTrace');
    } finally {
      exit(0);
    }
  }

  ProcessSignal.sigint.watch().listen(handleSignal);
  ProcessSignal.sigterm.watch().listen(handleSignal);
}

void _installAppExitHandler(Logger log) {
  _appLifecycleListener?.dispose();
  _appLifecycleListener = AppLifecycleListener(
    onExitRequested: () async {
      if (_signalShutdownInProgress) {
        return AppExitResponse.exit;
      }

      _signalShutdownInProgress = true;
      log.w('received app exit request, shutting down BitAssets runtime');

      try {
        if (GetIt.I.isRegistered<BinaryProvider>()) {
          await GetIt.I.get<BinaryProvider>().onShutdown();
        }
      } catch (error, stackTrace) {
        log.e('app exit shutdown failed: $error\n$stackTrace');
      }

      return AppExitResponse.exit;
    },
  );
}

Future<void> initAutoUpdater(Logger log) async {
  if (!Platform.isMacOS && !Platform.isWindows) {
    log.i('Skipping auto updater initialization because we are not on macOS or Windows');
    return;
  }

  try {
    const feedURL = 'https://releases.drivechain.info/appcast-bitassets.xml';
    log.i('Initializing auto updater with feed URL: $feedURL');

    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates(inBackground: true);

    log.i('Auto updater initialized successfully');
  } catch (e) {
    log.w('Failed to initialize auto updater: $e');
  }
}

// BitAssets window types
class SubWindowTypes {
  static const String debugId = 'debug';
  static const String logsId = 'logs';

  static var debug = SailWindow(
    identifier: debugId,
    name: 'Debug Window',
    defaultSize: Size(900, 700),
    defaultPosition: Offset(100, 100),
  );

  static var logs = SailWindow(
    identifier: logsId,
    name: 'Logs',
    defaultSize: Size(800, 600),
    defaultPosition: Offset(100, 100),
  );
}
