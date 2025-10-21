import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/fonts.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/console/integrated_console_view.dart';
import 'package:thunder/config/runtime_args.dart';
import 'package:thunder/providers/thunder_homepage_provider.dart';
import 'package:thunder/routing/router.dart';
import 'package:thunder/rpc/models/active_sidechains.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  try {
    final (applicationDir, logFile, log) = await init(args);

    if (args.contains('multi_window')) {
      return runMultiWindow(args, log, applicationDir, logFile);
    }

    await runMainWindow(log, applicationDir, logFile);
  } catch (e, stackTrace) {
    runErrorScreen(e, stackTrace);
  }
}

Future<(Directory, File, Logger)> init(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  addFontLicense();

  Directory? applicationDir;
  File? logFile;

  if (args.contains('multi_window')) {
    final arguments = jsonDecode(args[2]) as Map<String, dynamic>;

    if (arguments['application_dir'] != null) {
      applicationDir = Directory(arguments['application_dir']);
    }
    if (arguments['log_file'] != null) {
      logFile = File(arguments['log_file']);
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
    final thunder = ThunderLive();
    GetIt.I.registerSingleton<ThunderRPC>(thunder);

    return thunder;
  }

  await initSidechainDependencies(
    sidechainType: BinaryType.thunder,
    createSidechainConnection: createSidechainConnection,
    applicationDir: applicationDir,
    log: log,
  );

  // Register homepage provider
  final thunderHomepageProvider = ThunderHomepageProvider();
  GetIt.I.registerLazySingleton<ThunderHomepageProvider>(() => thunderHomepageProvider);
  // Register the abstract HomepageProvider as an alias to the concrete implementation
  GetIt.I.registerLazySingleton<HomepageProvider>(() => thunderHomepageProvider);

  return (applicationDir, logFile, log);
}

Future<void> runMultiWindow(
  List<String> args,
  Logger log,
  Directory applicationDir,
  File logFile,
) async {
  final arguments = jsonDecode(args[2]) as Map<String, dynamic>;

  Widget child = SailCard(
    child: SailText.primary15('no window type provided, the programmers messed up'),
  );

  switch (arguments['window_type']) {
    case SubWindowTypes.consoleId:
      child = const IntegratedConsoleView();
      break;
    case SubWindowTypes.logsId:
      child = LogPage(
        logPath: logFile.path,
        title: 'Thunder Logs',
      );
      break;
  }

  log.i('starting thunder in multi window');
  final thunder = GetIt.I.get<ThunderRPC>();

  return runApp(
    buildSailWindowApp(
      log,
      '${arguments['window_title'] as String} | Thunder',
      child,
      thunder.chain.color,
    ),
  );
}

Future<void> runMainWindow(Logger log, Directory applicationDir, File logFile) async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Thunder Sidechain',
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

  log.i('starting thunder');
  final thunder = GetIt.I.get<ThunderRPC>();
  final router = GetIt.I.get<AppRouter>();

  runApp(
    SailApp(
      dense: false,
      builder: (context) {
        return _ThunderAppContent(
          router: router,
          thunder: thunder,
        );
      },
      accentColor: thunder.chain.color,
      log: log,
    ),
  );
}

class _ThunderAppContent extends StatelessWidget {
  final AppRouter router;
  final ThunderRPC thunder;

  const _ThunderAppContent({
    required this.router,
    required this.thunder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: thunder.chain.name,
      theme: ThemeData(
        fontFamily: font == SailFontValues.ibmMono ? 'IBMPlexMono' : 'Inter',
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: thunder.chain.color),
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
  final thunder = binaryProvider.binaries.firstWhere((b) => b.type == BinaryType.thunder);

  await binaryProvider.startWithEnforcer(
    thunder,
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
