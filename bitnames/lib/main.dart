import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitnames/config/runtime_args.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:bitnames/routing/router.dart';
import 'package:bitnames/rpc/models/active_sidechains.dart';
import 'package:bitnames/widgets/containers/dropdownactions/console.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/sidechain_main.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
    case 'console':
      child = const ConsoleWindow();
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

  log.i('starting bitnames in multi window');
  final bitnames = GetIt.I.get<BitnamesRPC>();

  final sailApp = buildSailWindowApp(
    log,
    '${arguments['window_title'] as String} | BitNames',
    child,
    bitnames.chain.color,
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

  SidechainRPC createSidechainConnection(Binary binary) {
    final bitnames = BitnamesLive();
    GetIt.I.registerSingleton<BitnamesRPC>(bitnames);

    return bitnames;
  }

  await initSidechainDependencies(
    sidechainType: BinaryType.bitnames,
    createSidechainConnection: createSidechainConnection,
    applicationDir: applicationDir,
    store: store,
    log: log,
  );

  GetIt.I.registerLazySingleton<BitnamesProvider>(
    () => BitnamesProvider(),
  );

  return (applicationDir, logFile, log);
}

Future<void> start(List<String> args) async {
  final (applicationDir, logFile, log) = await init(args);

  if (args.contains('multi_window')) {
    return runMultiWindow(args, log, applicationDir, logFile);
  }

  await runMainWindow(log, applicationDir, logFile);
}

Future<void> runMainWindow(Logger log, Directory applicationDir, File logFile) async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Bitnames Sidechain',
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

  final router = GetIt.I.get<AppRouter>();
  final bitnames = GetIt.I.get<BitnamesRPC>();
  runApp(
    SailApp(
      dense: false,
      builder: (context) {
        return _BitnamesAppContent(
          router: router,
          bitnames: bitnames,
        );
      },
      accentColor: bitnames.chain.color,
      log: log,
    ),
  );
}

class _BitnamesAppContent extends StatelessWidget {
  final AppRouter router;
  final BitnamesRPC bitnames;

  const _BitnamesAppContent({
    required this.router,
    required this.bitnames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final font = theme.font;

    return MaterialApp.router(
      routerDelegate: router.delegate(),
      routeInformationParser: router.defaultRouteParser(),
      title: bitnames.chain.name,
      theme: ThemeData(
        fontFamily: font == SailFontValues.sourceCodePro ? 'SourceCodePro' : 'Inter',
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: bitnames.chain.color),
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
