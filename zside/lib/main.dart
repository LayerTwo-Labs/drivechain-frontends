import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:collection/collection.dart';
import 'package:zside/gen/version.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/fonts.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zside/config/runtime_args.dart';
import 'package:zside/providers/cast_provider.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/providers/zside_conf_provider.dart';
import 'package:zside/providers/zside_homepage_provider.dart';
import 'package:zside/providers/zside_provider.dart';
import 'package:zside/routing/router.dart';

void main(List<String> args) async {
  await withWindowsFileRetry(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Suppress harmless Flutter framework errors (mouse tracker, keyboard state)
      FlutterError.onError = (FlutterErrorDetails details) {
        final errorString = details.exception.toString();

        // Ignore known harmless desktop platform bugs
        if (errorString.contains('mouse_tracker.dart') ||
            errorString.contains('KeyDownEvent is dispatched') ||
            errorString.contains('_debugDuringDeviceUpdate')) {
          // Silently ignore these errors
          return;
        }

        // For all other errors, use default error handling
        FlutterError.presentError(details);
      };

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

  late ZSideLive zsideRPC;

  await initSidechainDependencies(
    sidechainType: BinaryType.BINARY_TYPE_ZSIDE,
    createSidechainConnection: (_) {
      zsideRPC = ZSideLive();
      GetIt.I.registerSingleton<ZSideRPC>(zsideRPC);
      return zsideRPC;
    },
    applicationDir: applicationDir,
    log: log,
    router: router,
    currentVersion: AppVersion.version,
    additionalBinaries: () => [Orchestratord()],
  );

  // Register OrchestratorRPC for communicating with zsided
  final orchestrator = OrchestratorRPC(host: 'localhost', port: 30303);
  GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);

  // Register BackendStateProvider for streaming binary status
  final backendState = BackendStateProvider(orchestrator);
  GetIt.I.registerSingleton<BackendStateProvider>(backendState);

  // Start zsided (Go backend), which orchestrates all binary lifecycle
  bootBinaries(log);

  // Initialize ZSideConfProvider (must be after BitcoinConfProvider)
  final zsideConfProvider = await ZSideConfProvider.create();
  GetIt.I.registerLazySingleton<GenericSidechainConfProvider>(() => zsideConfProvider);

  GetIt.I.registerLazySingleton<ZSideProvider>(
    () => ZSideProvider(),
  );

  GetIt.I.registerLazySingleton<CastProvider>(
    () => CastProvider(),
  );

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );

  final zsideHomepageProvider = ZSideHomepageProvider();
  GetIt.I.registerLazySingleton<ZSideHomepageProvider>(() => zsideHomepageProvider);
  GetIt.I.registerLazySingleton<HomepageProvider>(() => zsideHomepageProvider);

  return (applicationDir, logFile, log);
}

Future<void> runMultiWindow(
  String argumentsStr,
  Logger log,
  Directory applicationDir,
  File logFile,
) async {
  final arguments = jsonDecode(argumentsStr) as Map<String, dynamic>;

  Widget child = SailCard(
    child: SailText.primary15('no window type provided, the programmers messed up'),
  );

  final zside = GetIt.I.get<ZSideRPC>();

  switch (arguments['window_type']) {
    case SubWindowTypes.debugId:
      child = SidechainDebugWindow(
        rpc: zside,
        sidechainName: 'ZSide',
      );
      break;
    case SubWindowTypes.logsId:
      child = LogPage(
        logPath: logFile.path,
        title: 'ZSide Logs',
      );
      break;
  }

  log.i('starting zside in multi window');

  return runApp(
    buildSailWindowApp(
      log,
      '${arguments['window_title'] as String} | ZSide',
      child,
      zside.chain.color,
    ),
  );
}

Future<void> runMainWindow(Logger log, Directory applicationDir, File logFile) async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'ZSide Sidechain',
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

  await initAutoUpdater(log);

  log.i('starting zside');
  final zside = GetIt.I.get<ZSideRPC>();
  final router = GetIt.I.get<AppRouter>();

  runApp(
    SailApp(
      dense: false,
      builder: (context) {
        return _ZSideAppContent(
          router: router,
          zside: zside,
        );
      },
      accentColor: zside.chain.color,
      log: log,
    ),
  );
}

class _ZSideAppContent extends StatelessWidget {
  final AppRouter router;
  final ZSideRPC zside;

  const _ZSideAppContent({
    required this.router,
    required this.zside,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: zside.chain.name,
      theme: ThemeData(
        fontFamily: font == SailFontValues.ibmMono ? 'IBMPlexMono' : 'Inter',
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: zside.chain.color),
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

void bootBinaries(Logger log) async {
  try {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    // Seed the DaemonConnectionCard's "Initializing..." spinner + startup log
    // before ZSided has a chance to come up. Without this the card sits on
    // "Not connected" until BackendStateProvider's listBinaries poll lands
    // its first snapshot.
    final zsideRpc = GetIt.I.isRegistered<ZSideRPC>() ? GetIt.I.get<ZSideRPC>() : null;
    if (zsideRpc != null) {
      zsideRpc.initializingBinary = true;
      zsideRpc.connectionError = null;
      zsideRpc.markStateChanged();
    }
    binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_ZSIDE, 'Starting zsided...');
    binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_ZSIDED, 'Starting zsided...');

    // Start zsided via BinaryProvider (it's bundled, not downloaded)
    final zsided = binaryProvider.binaries.firstWhere((b) => b is ZSided);
    await binaryProvider.start(zsided);

    // Wait for zsided to be ready before calling StartWithL1
    log.i('bootBinaries: waiting for zsided readiness');
    binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_ZSIDE, 'Waiting for zsided...');
    binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_ZSIDED, 'Waiting for zsided...');
    final orchestrator = GetIt.I.get<OrchestratorRPC>();
    for (var i = 0; i < 30; i++) {
      try {
        await orchestrator.listBinaries();
        log.i('bootBinaries: zsided is ready');
        break;
      } catch (_) {
        if (i == 29) {
          log.e('bootBinaries: zsided did not become ready after 15s');
          return;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Start watching binary status stream — this owns clearing
    // initializingBinary once the orchestrator reports status.
    final backendState = GetIt.I.get<BackendStateProvider>();
    backendState.startWatching();

    // Fire-and-forget: server dispatches the boot goroutine and returns.
    // Download / connection state come from polled GetSyncStatus +
    // ListBinaries. The actual boot survives transport blips because the
    // server's goroutine ctx is detached from this call.
    log.i('bootBinaries: dispatching StartWithL1');
    await orchestrator.startWithL1('zside', targetArgs: ['--headless']);
    log.i('bootBinaries: StartWithL1 dispatched');
  } catch (e, st) {
    log.e('bootBinaries failed: $e\n$st');
  }
}

Future<void> initAutoUpdater(Logger log) async {
  if (!Platform.isMacOS && !Platform.isWindows) {
    log.i('Skipping auto updater initialization because we are not on macOS or Windows');
    return;
  }

  try {
    const feedURL = 'https://releases.drivechain.info/appcast-zside.xml';
    log.i('Initializing auto updater with feed URL: $feedURL');

    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates(inBackground: true);

    log.i('Auto updater initialized successfully');
  } catch (e) {
    log.w('Failed to initialize auto updater: $e');
  }
}

// ZSide window types
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
