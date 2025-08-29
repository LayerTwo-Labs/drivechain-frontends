import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/sidechain_main.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:thunder/config/runtime_args.dart';
import 'package:thunder/routing/router.dart';
import 'package:thunder/rpc/models/active_sidechains.dart';
import 'package:thunder/storage/sail_settings/font_settings.dart';
import 'package:thunder/widgets/containers/dropdownactions/console.dart';
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
  final store = await KeyValueStore.create(dir: applicationDir);

  final log = await logger(RuntimeArgs.fileLog, RuntimeArgs.consoleLog, logFile);
  GetIt.I.registerLazySingleton<Logger>(() => log);
  final router = AppRouter();
  GetIt.I.registerLazySingleton<AppRouter>(() => router);

  Future<SidechainRPC> createSidechainConnection(Binary binary) async {
    final thunder = ThunderLive();
    GetIt.I.registerSingleton<ThunderRPC>(thunder);

    return thunder;
  }

  await initSidechainDependencies(
    sidechainType: BinaryType.thunder,
    createSidechainConnection: createSidechainConnection,
    applicationDir: applicationDir,
    store: store,
    log: log,
  );

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
      child = const ConsoleWindow();
      break;
    case SubWindowTypes.logsId:
      child = LogPage(
        logPath: logFile.path,
        title: 'Thunder Logs',
      );
      break;
  }

  // Get client settings to check debug mode
  final clientSettings = GetIt.I<ClientSettings>();
  var debugMode = false;
  try {
    final debugModeSetting = await clientSettings.getValue(DebugModeSetting());
    debugMode = debugModeSetting.value;
    log.i('Debug mode setting loaded: $debugMode');
  } catch (error) {
    log.w('Failed to load debug mode setting, defaulting to false', error: error);
    // do absolutely nothing, probably no debug mode setting
  }

  log.i('starting thunder in multi window');
  final thunder = GetIt.I.get<ThunderRPC>();

  final sailApp = buildSailWindowApp(
    log,
    '${arguments['window_title'] as String} | Thunder',
    child,
    thunder.chain.color,
  );

  if (debugMode) {
    log.i('Initializing Sentry in debug mode');
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://fb54f18383071d144bd00f6159827dc5@o1053156.ingest.us.sentry.io/4509152512180224';
        options.tracesSampleRate = 0.0;
        options.profilesSampleRate = 0.0;
        options.recordHttpBreadcrumbs = false;
        options.sampleRate = 1.0;
        options.attachStacktrace = true;
        options.enablePrintBreadcrumbs = false;
        options.debug = false;
      },
      appRunner: () {
        log.i('Starting app with Sentry monitoring');
        return runApp(
          SentryWidget(
            child: sailApp,
          ),
        );
      },
    );
  } else {
    return runApp(
      sailApp,
    );
  }
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

  final font = (await GetIt.I.get<ClientSettings>().getValue(FontSetting())).value;

  log.i('starting thunder');
  final thunder = GetIt.I.get<ThunderRPC>();
  final router = GetIt.I.get<AppRouter>();

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (context) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: thunder.chain.name,
        theme: ThemeData(
          fontFamily: font == SailFontValues.sourceCodePro ? 'SourceCodePro' : 'Inter',
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: thunder.chain.color),
        ),
      ),
      accentColor: thunder.chain.color,
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
  final thunder = binaryProvider.binaries.firstWhere((b) => b is Thunder);

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
