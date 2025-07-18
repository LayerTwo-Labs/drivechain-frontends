import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitnames/config/runtime_args.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:bitnames/routing/router.dart';
import 'package:bitnames/rpc/models/active_sidechains.dart';
import 'package:bitnames/storage/sail_settings/font_settings.dart';
import 'package:bitnames/widgets/containers/dropdownactions/console.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/sidechain_main.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

Future<void> start(List<String> args) async {
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
    final bitnames = await BitnamesLive.create(
      binary: binary,
    );
    GetIt.I.registerSingleton<BitnamesRPC>(bitnames);

    return bitnames;
  }

  await initSidechainDependencies(
    sidechain: Bitnames(),
    createSidechainConnection: createSidechainConnection,
    applicationDir: applicationDir,
    store: store,
    log: log,
  );

  GetIt.I.registerLazySingleton<BitnamesProvider>(
    () => BitnamesProvider(),
  );

  log.i('starting bitnames');
  final bitnames = GetIt.I.get<BitnamesRPC>();

  if (args.contains('multi_window')) {
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

  final font = (await GetIt.I.get<ClientSettings>().getValue(FontSetting())).value;

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (context) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: bitnames.chain.name,
        theme: ThemeData(
          fontFamily: font == SailFontValues.sourceCodePro ? 'SourceCodePro' : 'Inter',
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: bitnames.chain.color),
        ),
      ),
      accentColor: bitnames.chain.color,
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

void main(List<String> args) async {
  // the application is launched function because some startup things
  // are async
  await start(args);
}

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initDependencies(
  Directory applicationDir,
  File logFile,
  KeyValueStore store,
) async {
  final log = await logger(RuntimeArgs.fileLog, RuntimeArgs.consoleLog, logFile);
  GetIt.I.registerLazySingleton<Logger>(() => log);

  GetIt.I.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(),
  );

  final clientSettings = ClientSettings(
    store: store,
    log: log,
  );
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => clientSettings,
  );
  final settingsProvider = await SettingsProvider.create();
  GetIt.I.registerLazySingleton<SettingsProvider>(
    () => settingsProvider,
  );

  // Load initial binary states
  final binaries = await _loadBinaries(applicationDir);
  final mainchainRPC = await MainchainRPCLive.create(
    binaries.firstWhere((b) => b is BitcoinCore),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );

  final enforcerBinary = binaries.firstWhere((b) => b is Enforcer);
  final enforcer = await EnforcerLive.create(
    host: '127.0.0.1',
    port: enforcerBinary.port,
    binary: enforcerBinary,
  );
  GetIt.I.registerSingleton<EnforcerRPC>(enforcer);

  final binary = binaries.firstWhere((b) => b is Bitnames);
  final bitnames = await BitnamesLive.create(
    binary: binary,
  );
  GetIt.I.registerSingleton<BitnamesRPC>(bitnames);
  GetIt.I.registerSingleton<SidechainRPC>(bitnames);

  // After RPCs including sidechain rpcs have been registered, register the binary provider
  final binaryProvider = BinaryProvider(
    appDir: applicationDir,
    initialBinaries: binaries,
  );
  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );
  bootBinaries(log);

  GetIt.I.registerLazySingleton<BMMProvider>(() => BMMProvider());

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => BalanceProvider(
      connections: [bitnames],
    ),
  );

  GetIt.I.registerLazySingleton<AddressProvider>(
    () => AddressProvider(),
  );

  final syncProvider = SyncProvider(
    additionalConnection: SyncConnection(
      rpc: bitnames,
      name: bitnames.binary.name,
    ),
  );
  GetIt.I.registerLazySingleton<SyncProvider>(
    () => syncProvider,
  );
  unawaited(syncProvider.fetch());

  GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(
    () => SidechainTransactionsProvider(),
  );
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
  final bitnames = binaryProvider.binaries.firstWhere((b) => b is Bitnames);

  await binaryProvider.startWithEnforcer(
    bitnames,
  );
}

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  // Register all binaries
  var binaries = [
    BitcoinCore(),
    Enforcer(),
    Bitnames(),
  ];

  // make bitassets boot in headless-mode
  binaries[2].addBootArg('--headless');

  return await loadBinaryCreationTimestamp(binaries, appDir);
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
