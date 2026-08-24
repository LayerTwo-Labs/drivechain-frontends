import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:auto_updater/auto_updater.dart';
import 'package:collection/collection.dart';
import 'package:inquisition/gen/version.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
// App shell needs MaterialApp + ThemeData; everything below uses sail_ui.
// ignore: avoid_material_import
import 'package:flutter/material.dart' show ColorScheme, MaterialApp, ThemeData;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/config/backend_sidechain_runtime.dart';
import 'package:sail_ui/config/fonts.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:inquisition/config/runtime_args.dart';
import 'package:inquisition/providers/inquisition_conf_provider.dart';
import 'package:inquisition/providers/inquisition_homepage_provider.dart';
import 'package:inquisition/routing/router.dart';
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
  if (!GetIt.I.isRegistered<Logger>()) {
    GetIt.I.registerLazySingleton<Logger>(() => log);
  }
  final router = GetIt.I.isRegistered<AppRouter>() ? GetIt.I.get<AppRouter>() : AppRouter();
  if (!GetIt.I.isRegistered<AppRouter>()) {
    GetIt.I.registerLazySingleton<AppRouter>(() => router);
  }

  late InquisitionRPC inquisitionRPC;

  await initSidechainDependencies(
    sidechainType: BinaryType.BINARY_TYPE_INQUISITION,
    createSidechainConnection: (_) {
      if (GetIt.I.isRegistered<InquisitionRPC>()) {
        inquisitionRPC = GetIt.I.get<InquisitionRPC>();
      } else {
        inquisitionRPC = InquisitionLive();
        GetIt.I.registerSingleton<InquisitionRPC>(inquisitionRPC);
      }
      return inquisitionRPC;
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
      binary: BinaryType.BINARY_TYPE_INQUISITION,
      appRpc: inquisitionRPC,
    ),
  );

  // Initialize InquisitionConfProvider (must be after BitcoinConfProvider)
  final inquisitionConfProvider = await InquisitionConfProvider.create();
  if (!GetIt.I.isRegistered<GenericSidechainConfProvider>()) {
    GetIt.I.registerLazySingleton<GenericSidechainConfProvider>(() => inquisitionConfProvider);
  }

  // Register homepage provider
  final inquisitionHomepageProvider = InquisitionHomepageProvider();
  if (!GetIt.I.isRegistered<InquisitionHomepageProvider>()) {
    GetIt.I.registerLazySingleton<InquisitionHomepageProvider>(() => inquisitionHomepageProvider);
  }
  // Register the abstract HomepageProvider as an alias to the concrete implementation
  if (!GetIt.I.isRegistered<HomepageProvider>()) {
    GetIt.I.registerLazySingleton<HomepageProvider>(() => inquisitionHomepageProvider);
  }

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

  final inquisition = GetIt.I.get<InquisitionRPC>();

  switch (arguments['window_type']) {
    case SubWindowTypes.debugId:
      child = SidechainDebugWindow(
        rpc: inquisition,
        sidechainName: 'Inquisition',
      );
      break;
    case SubWindowTypes.logsId:
      child = LogPage(
        logPath: logFile.path,
        title: 'Inquisition Logs',
      );
      break;
  }

  log.i('starting inquisition in multi window');

  return runApp(
    buildSailWindowApp(
      log,
      '${arguments['window_title'] as String} | Inquisition',
      child,
      inquisition.chain.color,
    ),
  );
}

void bootBinaries(Logger log) {
  unawaited(
    bootBackendManagedSidechain(
      log: log,
      binary: BinaryType.BINARY_TYPE_INQUISITION,
      appRpc: GetIt.I.isRegistered<InquisitionRPC>() ? GetIt.I.get<InquisitionRPC>() : null,
    ),
  );
}

Future<void> runMainWindow(Logger log, Directory applicationDir, File logFile) async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Inquisition Sidechain',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  // Initialize WindowProvider for the main window
  final windowProvider = await WindowProvider.newInstance(logFile, applicationDir, isMainWindow: true);
  if (!GetIt.I.isRegistered<WindowProvider>()) {
    GetIt.I.registerLazySingleton<WindowProvider>(() => windowProvider);
  }

  _installSignalShutdownHandlers(log);
  _installAppExitHandler(log);

  await initAutoUpdater(log);

  log.i('starting inquisition');
  final inquisition = GetIt.I.get<InquisitionRPC>();
  final router = GetIt.I.get<AppRouter>();

  runApp(
    SailApp(
      dense: false,
      builder: (context) {
        return _InquisitionAppContent(
          router: router,
          inquisition: inquisition,
        );
      },
      accentColor: inquisition.chain.color,
      log: log,
    ),
  );
}

class _InquisitionAppContent extends StatelessWidget {
  final AppRouter router;
  final InquisitionRPC inquisition;

  const _InquisitionAppContent({
    required this.router,
    required this.inquisition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: inquisition.chain.name,
      theme: ThemeData(
        fontFamily: theme.chrome.fontFamily ?? (font == SailFontValues.ibmMono ? 'IBMPlexMono' : 'Inter'),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: inquisition.chain.color),
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
  return prepareLogFile(datadir, 'debug.log');
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
    log.w('received ${signal.toString()}, shutting down Inquisition runtime');

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
      log.w('received app exit request, shutting down Inquisition runtime');

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
    const feedURL = 'https://releases.drivechain.info/appcast-inquisition.xml';
    log.i('Initializing auto updater with feed URL: $feedURL');

    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates(inBackground: true);

    log.i('Auto updater initialized successfully');
  } catch (e) {
    log.w('Failed to initialize auto updater: $e');
  }
}

// Inquisition window types
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
