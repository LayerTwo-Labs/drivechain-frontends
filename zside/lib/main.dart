import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zside/config/runtime_args.dart';
import 'package:zside/providers/cast_provider.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/providers/zside_provider.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/rpc/models/active_sidechains.dart';
import 'package:zside/storage/sail_settings/font_settings.dart';
import 'package:zside/widgets/containers/dropdownactions/console.dart';

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
  applicationDir ??= await getApplicationSupportDirectory();
  logFile ??= await getLogFile();
  final store = await KeyValueStore.create(dir: applicationDir);

  await initDependencies(applicationDir, logFile, store);

  AppRouter router = GetIt.I.get<AppRouter>();
  Logger log = GetIt.I.get<Logger>();

  log.i('starting zside');
  final zside = GetIt.I.get<ZSideRPC>();

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

    return runApp(
      buildSailWindowApp(
        log,
        '${arguments['window_title'] as String} | ZSide',
        child,
        zside.chain.color,
      ),
    );
  }

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

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (context) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: zside.chain.name,
        theme: ThemeData(
          fontFamily: font == SailFontValues.sourceCodePro ? 'SourceCodePro' : 'Inter',
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

  final zside = await ZSideLive.create(
    binary: binaries.firstWhere((b) => b is ZSide),
  );
  GetIt.I.registerSingleton<ZSideRPC>(zside);
  GetIt.I.registerSingleton<SidechainRPC>(zside);

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
      connections: [zside],
    ),
  );

  final syncProvider = SyncProvider(
    additionalConnection: SyncConnection(
      rpc: zside,
      name: zside.binary.name,
    ),
  );
  GetIt.I.registerLazySingleton<SyncProvider>(
    () => syncProvider,
  );
  unawaited(syncProvider.fetch());

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );

  GetIt.I.registerLazySingleton<ZSideProvider>(
    () => ZSideProvider(),
  );

  GetIt.I.registerLazySingleton<CastProvider>(
    () => CastProvider(),
  );
}

Future<File> getLogFile() async {
  final datadir = await RuntimeArgs.datadir();
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

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  // Register all binaries
  var binaries = [
    BitcoinCore(),
    Enforcer(),
    ZSide(),
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
