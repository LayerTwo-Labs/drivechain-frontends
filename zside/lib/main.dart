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
import 'package:sail_ui/widgets/console/integrated_console_view.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zside/config/runtime_args.dart';
import 'package:zside/providers/cast_provider.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/providers/zside_homepage_provider.dart';
import 'package:zside/providers/zside_provider.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/rpc/models/active_sidechains.dart';

void main(List<String> args) async {
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
    final zside = ZSideLive();
    GetIt.I.registerSingleton<ZSideRPC>(zside);

    return zside;
  }

  await initSidechainDependencies(
    sidechainType: BinaryType.zSide,
    createSidechainConnection: createSidechainConnection,
    applicationDir: applicationDir,
    log: log,
  );

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

void runMultiWindow(String argumentsStr, Logger log, Directory applicationDir, File logFile) {
  final arguments = jsonDecode(argumentsStr) as Map<String, dynamic>;
  log.i('starting zside in multi window');
  final zside = GetIt.I.get<ZSideRPC>();

  Widget child = SailCard(
    child: SailText.primary15('no window type provided, the programmers messed up'),
  );

  switch (arguments['window_type']) {
    case 'console':
      child = const IntegratedConsoleView();
      break;
  }

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
  final windowProvider = await WindowProvider.newInstance(logFile, applicationDir);
  GetIt.I.registerLazySingleton<WindowProvider>(() => windowProvider);

  final font = (await GetIt.I.get<ClientSettings>().getValue(FontSetting())).value;

  log.i('starting zside');
  final zside = GetIt.I.get<ZSideRPC>();
  final router = GetIt.I.get<AppRouter>();

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (context) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: zside.chain.name,
        theme: ThemeData(
          fontFamily: font == SailFontValues.ibmMono ? 'IBMPlexMono' : 'Inter',
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: zside.chain.color),
        ),
      ),
      accentColor: zside.chain.color,
      log: log,
    ),
  );
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
  final zside = binaryProvider.binaries.firstWhere((b) => b is ZSide);

  await binaryProvider.startWithEnforcer(
    zside,
  );
}

// BitAssets window types
class SubWindowTypes {
  static const String consoleId = 'console';
  static const String logsId = 'logs';

  static var console = SailWindow(
    identifier: consoleId,
    name: 'Console',
    defaultSize: Size(800, 600),
    defaultPosition: Offset(100, 100),
  );

  static var logs = SailWindow(
    identifier: logsId,
    name: 'Logs',
    defaultSize: Size(800, 600),
    defaultPosition: Offset(100, 100),
  );
}
