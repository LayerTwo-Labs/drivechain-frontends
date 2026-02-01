import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/fonts.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/config/runtime_args.dart';
import 'package:truthcoin/providers/truthcoin_conf_provider.dart';
import 'package:truthcoin/providers/truthcoin_homepage_provider.dart';
import 'package:truthcoin/routing/router.dart';
import 'package:window_manager/window_manager.dart';

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

  SidechainRPC createSidechainConnection(Binary binary) {
    final truthcoin = TruthcoinLive();
    GetIt.I.registerSingleton<TruthcoinRPC>(truthcoin);

    return truthcoin;
  }

  await initSidechainDependencies(
    sidechainType: BinaryType.truthcoin,
    createSidechainConnection: createSidechainConnection,
    applicationDir: applicationDir,
    log: log,
    router: router,
  );

  // Initialize TruthcoinConfProvider (must be after BitcoinConfProvider)
  final truthcoinConfProvider = await TruthcoinConfProvider.create();
  GetIt.I.registerLazySingleton<TruthcoinConfProvider>(() => truthcoinConfProvider);
  GetIt.I.registerLazySingleton<GenericSidechainConfProvider>(() => truthcoinConfProvider);

  // Register homepage provider
  final truthcoinHomepageProvider = TruthcoinHomepageProvider();
  GetIt.I.registerLazySingleton<TruthcoinHomepageProvider>(() => truthcoinHomepageProvider);
  // Register the abstract HomepageProvider as an alias to the concrete implementation
  GetIt.I.registerLazySingleton<HomepageProvider>(() => truthcoinHomepageProvider);

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

  final truthcoin = GetIt.I.get<TruthcoinRPC>();

  switch (arguments['window_type']) {
    case SubWindowTypes.debugId:
      child = SidechainDebugWindow(
        rpc: truthcoin,
        sidechainName: 'Truthcoin',
      );
      break;
    case SubWindowTypes.logsId:
      child = LogPage(
        logPath: logFile.path,
        title: 'Truthcoin Logs',
      );
      break;
  }

  log.i('starting truthcoin in multi window');

  return runApp(
    buildSailWindowApp(
      log,
      '${arguments['window_title'] as String} | Truthcoin',
      child,
      truthcoin.chain.color,
    ),
  );
}

Future<void> runMainWindow(Logger log, Directory applicationDir, File logFile) async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Truthcoin Sidechain',
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

  log.i('starting truthcoin');
  final truthcoin = GetIt.I.get<TruthcoinRPC>();
  final router = GetIt.I.get<AppRouter>();

  runApp(
    SailApp(
      dense: false,
      builder: (context) {
        return _TruthcoinAppContent(
          router: router,
          truthcoin: truthcoin,
        );
      },
      accentColor: truthcoin.chain.color,
      log: log,
    ),
  );
}

class _TruthcoinAppContent extends StatelessWidget {
  final AppRouter router;
  final TruthcoinRPC truthcoin;

  const _TruthcoinAppContent({
    required this.router,
    required this.truthcoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: truthcoin.chain.name,
      theme: ThemeData(
        fontFamily: font == SailFontValues.ibmMono ? 'IBMPlexMono' : 'Inter',
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: truthcoin.chain.color),
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
  final BinaryProvider binaryProvider = GetIt.I.get<BinaryProvider>();
  final truthcoin = binaryProvider.binaries.firstWhere((b) => b.type == BinaryType.truthcoin);

  await binaryProvider.startWithEnforcer(
    truthcoin,
  );
}

// Truthcoin window types
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
