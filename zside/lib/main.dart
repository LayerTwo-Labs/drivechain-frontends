import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zside/config/runtime_args.dart';
import 'package:zside/providers/cast_provider.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/providers/zcash_provider.dart';
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

  // Fall back to filesystem if not provided in args
  applicationDir ??= await getApplicationSupportDirectory();
  logFile ??= await getLogFile();
  final store = await KeyValueStore.create(dir: applicationDir);

  await initDependencies(applicationDir, logFile, store);

  AppRouter router = GetIt.I.get<AppRouter>();
  Logger log = GetIt.I.get<Logger>();

  log.i('starting thunder');
  final thunder = GetIt.I.get<ZCashRPC>();

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
      SailApp(
        log: log,
        dense: true,
        builder: (context) => MaterialApp(
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            fontFamily: 'Inter',
          ),
          home: Scaffold(
            body: child,
          ),
        ),
        accentColor: thunder.chain.color,
      ),
    );
  }

  final font = (await GetIt.I.get<ClientSettings>().getValue(FontSetting())).value;

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

  // Load initial binary states
  final binaries = await _loadBinaries(applicationDir);
  final mainchainRPC = await MainchainRPCLive.create(
    binaries.firstWhere((b) => b is BitcoinCore),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );

  final launcherAppDir = Directory(
    path.join(
      applicationDir.path,
      '..',
      'com.layertwolabs.launcher',
    ),
  );
  final enforcerBinary = binaries.firstWhere((b) => b is Enforcer);
  final enforcer = await EnforcerLive.create(
    host: '127.0.0.1',
    port: enforcerBinary.port,
    binary: enforcerBinary,
    launcherAppDir: launcherAppDir,
  );
  GetIt.I.registerSingleton<EnforcerRPC>(enforcer);

  final zcash = MockZCashRPCLive(
    storage: store,
  );
  GetIt.I.registerSingleton<ZCashRPC>(zcash);

  // After RPCs including sidechain rpcs have been registered, register the binary provider
  final binaryProvider = BinaryProvider(
    appDir: applicationDir,
    initialBinaries: binaries,
  );

  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );

  bootBinaries(log);

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => BalanceProvider(
      connections: [zcash],
    ),
  );

  final syncProvider = SyncProvider(
    additionalConnection: SyncConnection(
      rpc: zcash,
      name: zcash.binary.name,
    ),
  );
  GetIt.I.registerLazySingleton<SyncProvider>(
    () => syncProvider,
  );
  unawaited(syncProvider.fetch());

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );

  GetIt.I.registerLazySingleton<ZCashProvider>(
    () => ZCashProvider(),
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
  final thunder = binaryProvider.binaries.firstWhere((b) => b is Thunder);

  await binaryProvider.startWithEnforcer(
    thunder,
  );
}

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  // Register all binaries
  var binaries = [
    BitcoinCore(),
    Enforcer(),
    Thunder(),
  ];

  return await loadBinaryCreationTimestamp(binaries, appDir);
}
