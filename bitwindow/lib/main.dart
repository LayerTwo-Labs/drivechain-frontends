import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/pages/debug_window.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/content_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/providers/price_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await findSystemLocale();
  await initializeDateFormatting();

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
  applicationDir ??= await Environment.datadir();
  logFile ??= await getLogFile();

  final log = await logger(Environment.fileLog, Environment.consoleLog, logFile);
  log.i('starting bitwindow, writing logs to $logFile');

  await initDependencies(
    log,
    logFile,
    applicationDir: applicationDir,
  );

  Environment.validateAtRuntime();

  if (args.contains('multi_window')) {
    final arguments = jsonDecode(args[2]) as Map<String, dynamic>;

    Widget child = SailCard(
      title: 'no window type provided, the programmers messed up',
      child: SailText.primary15('no window type provided, the programmers messed up'),
    );

    switch (arguments['window_type']) {
      case 'debug':
        child = DebugWindow(
          // can't open a new window from a new window!
          newWindowIdentifier: null,
        );
        break;
      case 'deniability':
        child = DeniabilityTab(
          newWindowIdentifier: null,
        );
        break;
      case 'block_explorer':
        child = const BlockExplorerDialog(
          newWindowIdentifier: null,
        );
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
        accentColor: const Color.fromARGB(255, 255, 153, 0),
      ),
    );
  }

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Bitcoin Core + CUSF BIP 300/301 Enforcer',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  unawaited(bootBinaries(log));
  await setupSignalHandlers(log);

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
        return runApp(SentryWidget(child: BitwindowApp(log: log)));
      },
    );
  } else {
    log.i('Starting app without Sentry monitoring');
    runApp(BitwindowApp(log: log));
  }
}

Future<void> initDependencies(
  Logger log,
  File logFile, {
  required Directory applicationDir,
}) async {
  // Create platform-appropriate storage
  final storage = await KeyValueStore.create(dir: applicationDir);

  // Register the logger
  GetIt.I.registerLazySingleton<Logger>(() => log);

  // Register the router
  GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());

  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: storage,
      log: log,
    ),
  );

  final contentProvider = ContentProvider();
  GetIt.I.registerLazySingleton<ContentProvider>(
    () => contentProvider,
  );
  unawaited(contentProvider.load());

  PriceProvider priceProvider = PriceProvider();
  GetIt.I.registerLazySingleton<PriceProvider>(
    () => priceProvider,
  );
  unawaited(priceProvider.fetch());

  // Load initial binary states
  final binaries = await _loadBinaries(applicationDir);

  final mainchain = await MainchainRPCLive.create(
    binaries.firstWhere((b) => b is BitcoinCore),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchain,
  );

  final launcherAppDir = Directory(
    path.join(
      applicationDir.path,
      '..',
      'drivechain-launcher',
    ),
  );
  final enforcer = await EnforcerLive.create(
    host: '127.0.0.1',
    port: binaries[1].port,
    binary: binaries.firstWhere((b) => b is Enforcer),
    launcherAppDir: launcherAppDir,
  );
  GetIt.I.registerLazySingleton<EnforcerRPC>(
    () => enforcer,
  );

  final bitwindow = await BitwindowRPCLive.create(
    host: Environment.bitwindowdHost.value,
    port: Environment.bitwindowdPort.value,
    binary: binaries.firstWhere((b) => b is BitWindow),
  );
  GetIt.I.registerLazySingleton<BitwindowRPC>(
    () => bitwindow,
  );

  // now register all sidedchains
  final bitassetsBinary = binaries.firstWhere((b) => b is BitAssets);
  final bitassets = await BitAssetsLive.create(
    binary: bitassetsBinary,
    chain: Sidechain.fromBinary(bitassetsBinary),
  );
  GetIt.I.registerLazySingleton<BitAssetsRPC>(
    () => bitassets,
  );

  final bitnamesBinary = binaries.firstWhere((b) => b is Bitnames);
  final bitnames = await BitnamesLive.create(
    binary: bitnamesBinary,
    chain: Sidechain.fromBinary(bitnamesBinary),
  );
  GetIt.I.registerLazySingleton<BitnamesRPC>(
    () => bitnames,
  );

  final thunderBinary = binaries.firstWhere((b) => b is Thunder);
  final thunder = await ThunderLive.create(
    binary: thunderBinary,
    chain: Sidechain.fromBinary(thunderBinary),
  );
  GetIt.I.registerLazySingleton<ThunderRPC>(
    () => thunder,
  );

  // After RPCs have been registered, register the binary provider
  final binaryProvider = BinaryProvider(
    appDir: applicationDir,
    initialBinaries: binaries,
  );
  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );

  // Register all the providers
  final balanceProvider = BalanceProvider(
    connections: [bitwindow],
  );
  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => balanceProvider,
  );
  unawaited(balanceProvider.fetch());

  final syncProvider = SyncProvider(
    additionalConnection: SyncConnection(
      rpc: bitwindow,
      name: bitwindow.binary.name,
    ),
  );
  GetIt.I.registerLazySingleton<SyncProvider>(
    () => syncProvider,
  );
  unawaited(syncProvider.fetch());

  final blockchainProvider = BlockchainProvider();
  GetIt.I.registerLazySingleton<BlockchainProvider>(
    () => blockchainProvider,
  );
  unawaited(blockchainProvider.fetch());

  final txProvider = TransactionProvider();
  GetIt.I.registerLazySingleton<TransactionProvider>(
    () => txProvider,
  );
  unawaited(txProvider.fetch());

  final newsProvider = NewsProvider();
  GetIt.I.registerLazySingleton<NewsProvider>(
    () => newsProvider,
  );
  unawaited(newsProvider.fetch());

  final sidechainProvider = SidechainProvider();
  GetIt.I.registerLazySingleton<SidechainProvider>(
    () => sidechainProvider,
  );
  unawaited(sidechainProvider.fetch());

  final addressBookProvider = AddressBookProvider();
  GetIt.I.registerLazySingleton<AddressBookProvider>(
    () => addressBookProvider,
  );
  unawaited(addressBookProvider.fetch());

  final hdWalletProvider = HDWalletProvider(applicationDir);
  GetIt.I.registerLazySingleton<HDWalletProvider>(
    () => hdWalletProvider,
  );
  unawaited(hdWalletProvider.init());

  final bitdriveProvider = BitDriveProvider();
  GetIt.I.registerLazySingleton<BitDriveProvider>(
    () => bitdriveProvider,
  );
  unawaited(bitdriveProvider.init());
}

void ignoreOverflowErrors(
  FlutterErrorDetails details, {
  bool forceReport = false,
}) {
  bool ifIsOverflowError = false;

  // Detect overflow error.
  var exception = details.exception;
  if (exception is FlutterError) {
    ifIsOverflowError = !exception.diagnostics.any(
      (e) => e.value.toString().startsWith('A RenderFlex overflowed by'),
    );
  }

  // Ignore if is overflow error.
  if (ifIsOverflowError) {
    debugPrint('ignored overflow error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}

Future<File> getLogFile() async {
  final datadir = await Environment.datadir();
  await datadir.create(recursive: true);

  final path = [datadir.path, 'debug.log'].join(Platform.pathSeparator);
  final logFile = File(path);

  return logFile;
}

class BitwindowApp extends StatelessWidget {
  final Logger log;

  const BitwindowApp({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final router = GetIt.I.get<AppRouter>();

    return SailApp(
      log: log,
      dense: true,
      builder: (context) {
        return MaterialApp.router(
          routerDelegate: router.delegate(),
          routeInformationParser: router.defaultRouteParser(),
          title: 'Bitcoin Core + CUSF BIP 300/301 Enforcer',
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            fontFamily: 'Inter',
          ),
        );
      },
      accentColor: const Color.fromARGB(255, 255, 153, 0),
    );
  }
}

Future<void> bootBinaries(Logger log) async {
  log.i('STARTUP: Booting binaries');

  final BinaryProvider binaryProvider = GetIt.I.get<BinaryProvider>();
  final bitwindow = binaryProvider.binaries.firstWhere((b) => b is BitWindow);

  final mainchainRPC = GetIt.I.get<MainchainRPC>();
  final enforcerRPC = GetIt.I.get<EnforcerRPC>();

  await mainchainRPC.testConnection();
  await enforcerRPC.testConnection();

  if (!mainchainRPC.connected) {
    log.i('MainchainRPC not connected, adding --gui-booted-mainchain boot arg');
    bitwindow.addBootArg('--gui-booted-mainchain');
  }
  if (!enforcerRPC.connected) {
    log.i('EnforcerRPC not connected, adding --gui-booted-enforcer boot arg');
    bitwindow.addBootArg('--gui-booted-enforcer');
  }

  await binaryProvider.startWithEnforcer(
    bitwindow,
    // bitwindow can start without the enforcer
    bootExtraBinaryImmediately: true,
  );
}

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  // Register all binaries
  final binaries = [
    BitcoinCore(),
    Enforcer(),
    BitWindow(),
    BitAssets(),
    Bitnames(),
    Thunder(),
  ];

  return await loadBinaryCreationTimestamp(binaries, appDir);
}

Future<void> setupSignalHandlers(Logger log) async {
  ProcessSignal.sigint.watch().listen((signal) async {
    log.i('Received SIGINT, shutting down...');
    await GetIt.I.get<BinaryProvider>().onShutdown();
    exit(0);
  });

  // SIGTERM is not supported on Windows
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((signal) async {
      log.i('Received SIGTERM, shutting down...');
      await GetIt.I.get<BinaryProvider>().onShutdown();
      exit(0);
    });
  }

  if (Platform.isWindows) {
    // Handle shutdown via stdin (for Windows)
    stdin.transform(utf8.decoder).listen(
      (line) async {
        if (line.trim() == 'shutdown') {
          log.i('Received shutdown command via stdin');
          await GetIt.I.get<BinaryProvider>().onShutdown();
          exit(0);
        }
      },
      onDone: () async {
        // Triggered if stdin is closed
        log.i('STDIN closed, shutting down...');
        await GetIt.I.get<BinaryProvider>().onShutdown();
        exit(0);
      },
    );
  }
}
