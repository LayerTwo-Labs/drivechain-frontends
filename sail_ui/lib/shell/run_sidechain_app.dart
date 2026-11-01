import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart' show ColorScheme, MaterialApp, ThemeData;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/fonts.dart';
import 'package:sail_ui/config/sidechain_main.dart' show getLogFile;
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/chain_navigator.dart';
import 'package:sail_ui/shell/sidechain_homepage_provider.dart';
import 'package:sail_ui/shell/sidechain_module.dart';
import 'package:sidechain_core/config/backend_sidechain_runtime.dart';
import 'package:window_manager/window_manager.dart';

bool _signalShutdownInProgress = false;
AppLifecycleListener? _appLifecycleListener;

/// Runs one sidechain app: a sub-window when the engine got arguments, else the main window.
Future<void> runSidechainApp(SidechainModule module) async {
  await withWindowsFileRetry(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      final windowController = await WindowController.fromCurrentEngine();

      final (applicationDir, logFile, log) = await _init(module, windowController.arguments);

      if (windowController.arguments.isNotEmpty) {
        return await _runMultiWindow(module, windowController.arguments, log, logFile);
      }

      await _runMainWindow(module, log, applicationDir, logFile);
    } catch (e, stackTrace) {
      runErrorScreen(e, stackTrace);
    }
  });
}

Future<(Directory, File, Logger)> _init(SidechainModule module, String arguments) async {
  addFontLicense();

  Directory? applicationDir;
  File? logFile;

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

  final runtimeArgs = SidechainRuntimeArgs(module.chain.registryKey.toUpperCase());
  applicationDir ??= await runtimeArgs.datadir();
  logFile ??= await getLogFile(applicationDir);

  final log = await logger(runtimeArgs.fileLog, runtimeArgs.consoleLog, logFile);
  if (!GetIt.I.isRegistered<Logger>()) {
    GetIt.I.registerLazySingleton<Logger>(() => log);
  }
  if (!GetIt.I.isRegistered<SidechainModule>()) {
    GetIt.I.registerSingleton<SidechainModule>(module);
  }
  final router = module.registerRouter(GetIt.I);
  if (!GetIt.I.isRegistered<RootStackRouter>()) {
    GetIt.I.registerLazySingleton<RootStackRouter>(() => router);
  }
  if (!GetIt.I.isRegistered<ChainNavigator>()) {
    GetIt.I.registerSingleton<ChainNavigator>(ShellChainNavigator(router));
  }

  late SidechainRPC rpc;

  await initSidechainDependencies(
    sidechainType: module.chain.type,
    createSidechainConnection: (_) {
      rpc = module.registerRPC(GetIt.I);
      return rpc;
    },
    applicationDir: applicationDir,
    log: log,
    router: router,
    currentVersion: module.version.version,
    additionalBinaries: () => [Drivechaind()],
  );

  unawaited(
    initBackendManagedSidechainRuntime(
      log: log,
      binary: module.chain.type,
      appRpc: rpc,
    ),
  );

  // Must come after BitcoinConfProvider.
  final confProvider = await SidechainConfProvider.backed(sidechainConfProvider(module));
  if (!GetIt.I.isRegistered<GenericSidechainConfProvider>()) {
    GetIt.I.registerLazySingleton<GenericSidechainConfProvider>(() => confProvider);
  }

  await module.registerChainProviders(GetIt.I, applicationDir, log);
  await module.registerAppProviders(GetIt.I, log);

  final homepageProvider = SidechainHomepageProvider(module);
  if (!GetIt.I.isRegistered<SidechainHomepageProvider>()) {
    GetIt.I.registerLazySingleton<SidechainHomepageProvider>(() => homepageProvider);
  }

  return (applicationDir, logFile, log);
}

Future<void> _runMultiWindow(
  SidechainModule module,
  String argumentsStr,
  Logger log,
  File logFile,
) async {
  final arguments = jsonDecode(argumentsStr) as Map<String, dynamic>;

  Widget child = SailCard(
    child: SailText.primary15('no window type provided, the programmers messed up'),
  );

  final rpc = GetIt.I.get<SidechainRPC>();

  switch (arguments['window_type']) {
    case SidechainSubWindows.debugId:
      child = SidechainDebugWindow(
        rpc: rpc,
        sidechainName: module.fullName,
      );
      break;
    case SidechainSubWindows.logsId:
      child = LogPage(
        logPath: logFile.path,
        title: '${module.appName} Logs',
      );
      break;
  }

  log.i('starting ${module.chain.registryKey} in multi window');

  return runApp(
    buildSailWindowApp(
      log,
      '${arguments['window_title'] as String} | ${module.appName}',
      child,
      rpc.chain.color,
    ),
  );
}

SidechainConfProvider sidechainConfProvider(SidechainModule module) {
  return SidechainConfProvider(
    chain: module.chain,
    appName: module.fullName,
    dataDir: module.confDir,
    networkPorts: module.confPorts,
    defaultConf: module.defaultConf,
    skippedCliKeys: module.confSkippedCliKeys,
  );
}

void bootSidechainBinaries(SidechainModule module, Logger log) {
  unawaited(
    bootBackendManagedSidechain(
      log: log,
      binary: module.chain.type,
      appRpc: GetIt.I.isRegistered<SidechainRPC>() ? GetIt.I.get<SidechainRPC>() : null,
    ),
  );
}

Future<void> _runMainWindow(SidechainModule module, Logger log, Directory applicationDir, File logFile) async {
  await windowManager.ensureInitialized();
  final windowOptions = WindowOptions(
    minimumSize: const Size(400, 400),
    size: const Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: '${module.appName} Sidechain',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  final windowProvider = await WindowProvider.newInstance(logFile, applicationDir, isMainWindow: true);
  if (!GetIt.I.isRegistered<WindowProvider>()) {
    GetIt.I.registerLazySingleton<WindowProvider>(() => windowProvider);
  }

  _installSignalShutdownHandlers(module, log);
  _installAppExitHandler(module, log);

  await _initAutoUpdater(module, log);

  log.i('starting ${module.chain.registryKey}');
  final rpc = GetIt.I.get<SidechainRPC>();
  final router = GetIt.I.get<RootStackRouter>();

  runApp(
    SailApp(
      dense: false,
      builder: (context) {
        return _SidechainAppContent(
          router: router,
          rpc: rpc,
        );
      },
      accentColor: rpc.chain.color,
      log: log,
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    module.onFirstFrame();
  });
}

class _SidechainAppContent extends StatelessWidget {
  final RootStackRouter router;
  final SidechainRPC rpc;

  const _SidechainAppContent({
    required this.router,
    required this.rpc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: rpc.chain.name,
      theme: ThemeData(
        fontFamily: theme.chrome.fontFamily ?? (font == SailFontValues.ibmMono ? SailFonts.mono : SailFonts.inter),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: rpc.chain.color),
      ),
    );
  }
}

void _installSignalShutdownHandlers(SidechainModule module, Logger log) {
  if (Platform.isWindows) {
    return;
  }

  Future<void> handleSignal(ProcessSignal signal) async {
    if (_signalShutdownInProgress) {
      return;
    }

    _signalShutdownInProgress = true;
    log.w('received ${signal.toString()}, shutting down ${module.appName} runtime');

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

void _installAppExitHandler(SidechainModule module, Logger log) {
  _appLifecycleListener?.dispose();
  _appLifecycleListener = AppLifecycleListener(
    onExitRequested: () async {
      if (_signalShutdownInProgress) {
        return AppExitResponse.exit;
      }

      _signalShutdownInProgress = true;
      log.w('received app exit request, shutting down ${module.appName} runtime');

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

Future<void> _initAutoUpdater(SidechainModule module, Logger log) async {
  if (!Platform.isMacOS && !Platform.isWindows) {
    log.i('Skipping auto updater initialization because we are not on macOS or Windows');
    return;
  }

  try {
    final feedURL = 'https://releases.drivechain.info/appcast-${module.chain.registryKey}.xml';
    log.i('Initializing auto updater with feed URL: $feedURL');

    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates(inBackground: true);

    log.i('Auto updater initialized successfully');
  } catch (e) {
    log.w('Failed to initialize auto updater: $e');
  }
}

class SidechainSubWindows {
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
