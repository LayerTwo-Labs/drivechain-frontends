import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/pages/debug_window.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet_page.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/content_provider.dart';
import 'package:bitwindow/providers/denial_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
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

    Widget child = SailRawCard(
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
    minimumSize: Size(600, 700),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Bitcoin Core + CUSF BIP 300/301 Activator',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  runApp(BitwindowApp(log: log));
}

Future<void> initDependencies(
  Logger log,
  File logFile, {
  required Directory applicationDir,
}) async {
  // Create platform-appropriate storage
  final storage = await KeyValueStore.create(dir: applicationDir);

  var serverLogFile = [logFile.parent.path, 'debug.log'].join(Platform.pathSeparator);
  log.i('logging server logs to: $serverLogFile');

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

  final processProvider = ProcessProvider(
    appDir: applicationDir,
  );
  GetIt.I.registerLazySingleton<ProcessProvider>(
    () => processProvider,
  );

  final contentProvider = ContentProvider();
  GetIt.I.registerLazySingleton<ContentProvider>(
    () => contentProvider,
  );
  unawaited(contentProvider.load());

  // Load initial binary states
  final binaries = await _loadBinaries(applicationDir);

  final mainchain = await MainchainRPCLive.create(
    binaries[0],
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchain,
  );

  final enforcer = await EnforcerLive.create(
    host: '127.0.0.1',
    port: binaries[1].port,
    binary: binaries[1],
  );

  GetIt.I.registerLazySingleton<EnforcerRPC>(
    () => enforcer,
  );

  final bitwindow = await BitwindowRPCLive.create(
    host: Environment.bitwindowdHost.value,
    port: Environment.bitwindowdPort.value,
    binary: binaries[2],
  );
  GetIt.I.registerLazySingleton<BitwindowRPC>(
    () => bitwindow,
  );

  // After RPCs have been registered, register the binary provider
  final binaryProvider = BinaryProvider(
    appDir: applicationDir,
    initialBinaries: binaries,
  );
  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );

  final balanceProvider = BalanceProvider(
    connections: [bitwindow],
  );
  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => balanceProvider,
  );
  unawaited(balanceProvider.fetch());

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

  final denialProvider = DenialProvider();
  GetIt.I.registerLazySingleton<DenialProvider>(
    () => denialProvider,
  );
  unawaited(denialProvider.fetch());

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
          title: 'Bitcoin Core + CUSF BIP 300/301 Activator',
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

Future<void> initBinaries(
  Logger log,
  BuildContext context,
) async {
  final BinaryProvider binaryProvider = GetIt.I.get<BinaryProvider>();

  await binaryProvider.downloadThenBootL1(context);
}

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  // Register all binaries
  var binaries = [
    ParentChain(),
    Enforcer(),
    BitWindow(),
  ];

  return await loadBinaryMetadata(binaries, appDir);
}
