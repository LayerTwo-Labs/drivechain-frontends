import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet_page.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/content_provider.dart';
import 'package:bitwindow/providers/denial_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart' as protobuf;
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:connectrpc/protocol/grpc.dart' as grpc;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
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
      case 'deniability':
        child = DeniabilityTab();
        break;
      case 'block_explorer':
        child = const BlockExplorerDialog();
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

  GetIt.I.registerLazySingleton<ProcessProvider>(
    () => ProcessProvider(),
  );

  final contentProvider = ContentProvider();
  GetIt.I.registerLazySingleton<ContentProvider>(
    () => contentProvider,
  );
  unawaited(contentProvider.load());

  final mainchain = await MainchainRPCLive.create(
    ParentChain(),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchain,
  );

  var serverLogFile = [logFile.parent.path, 'debug.log'].join(Platform.pathSeparator);
  log.i('logging server logs to: $serverLogFile');
  final baseUrl = 'http://${Environment.bitwindowdHost.value}:${Environment.bitwindowdPort.value}';
  final httpClient = createHttpClient();
  final connectTransport = connect.Transport(
    baseUrl: baseUrl,
    codec: const protobuf.ProtoCodec(),
    httpClient: httpClient,
  );
  final bitwindow = await BitwindowRPCLive.create(
    transport: connectTransport,
    binary: BitWindow(),
  );
  GetIt.I.registerLazySingleton<BitwindowRPC>(
    () => bitwindow,
  );

  final enforerBinary = Enforcer();
  final enforcer = await EnforcerLive.create(
    transport: grpc.Transport(
      baseUrl: 'http://127.0.0.1:${enforerBinary.port}',
      codec: const protobuf.ProtoCodec(),
      httpClient: httpClient,
      statusParser: const protobuf.StatusParser(),
    ),
    binary: enforerBinary,
  );

  GetIt.I.registerLazySingleton<EnforcerRPC>(
    () => enforcer,
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
