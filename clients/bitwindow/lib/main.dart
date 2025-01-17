import 'dart:async';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/balance_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment.validateAtRuntime();

  final logFile = await getLogFile();
  final log = await logger(Environment.fileLog, Environment.consoleLog, logFile);
  log.i('starting bitwindow, writing logs to $logFile');
  await initDependencies(log, logFile);

  MainchainRPC mainchain = GetIt.I.get<MainchainRPC>();

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

  final router = GetIt.I.get<AppRouter>();

  return runApp(
    SailApp(
      dense: true,
      builder: (context) {
        return MaterialApp.router(
          routerDelegate: router.delegate(),
          routeInformationParser: router.defaultRouteParser(),
          title: 'Drivechain',
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            fontFamily: 'Inter',
          ),
        );
      },
      initMethod: (context) async {
        try {
          // first, set all binaries as initializing
          mainchain.initializingBinary = true;
          GetIt.I.get<EnforcerRPC>().initializingBinary = true;
          GetIt.I.get<BitwindowRPC>().initializingBinary = true;

          await initMainchainBinary(context, log, mainchain);
          log.i(
            'mainchain inited: ibd complete, ready to start enforcer',
          );

          if (!context.mounted) return;
          await initEnforcer(context, log);

          if (!context.mounted) return;
          await initBitwindow(context, log);
          log.i(
            'server inited: ready to serve frontend',
          );
        } catch (e) {
          log.e('could not init necessary binaries: $e');
        }
      },
      accentColor: const Color.fromARGB(255, 255, 153, 0),
      log: log,
    ),
  );
}

Future<void> initDependencies(Logger log, File logFile) async {
  final prefs = await SharedPreferences.getInstance();

  // Register the logger
  GetIt.I.registerLazySingleton<Logger>(() => log);

  // Register the router
  GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());

  // Needed for sail_ui to work
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
      log: log,
    ),
  );

  GetIt.I.registerLazySingleton<ProcessProvider>(
    () => ProcessProvider(),
  );

  NodeConnectionSettings mainchainConf = NodeConnectionSettings.empty();
  try {
    final network = 'signet';
    mainchainConf = await readRPCConfig(ParentChain().datadir(), 'bitcoin.conf', ParentChain(), network);
  } catch (error) {
    log.e('could not read mainchain conf: $error');
    // do nothing
  }

  var serverLogFile = [logFile.parent.path, 'debug.log'].join(Platform.pathSeparator);
  log.i('logging server logs to: $serverLogFile');
  GetIt.I.registerLazySingleton<BitwindowRPC>(
    () => BitwindowRPCLive(
      host: env(Environment.bitwindowdHost),
      port: env(Environment.bitwindowdPort),
      conf: mainchainConf,
      binary: BitWindow(),
      logPath: serverLogFile,
    ),
  );

  final enforcer = EnforcerLive(
    conf: mainchainConf,
    binary: Enforcer(),
    logPath: serverLogFile,
  );

  GetIt.I.registerLazySingleton<EnforcerRPC>(
    () => enforcer,
  );

  final balanceProvider = BalanceProvider();
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

  final mainchainRPC = await MainchainRPCLive.create(
    mainchainConf,
    ParentChain(),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );
}

Future<void> initMainchainBinary(
  BuildContext context,
  Logger log,
  MainchainRPC mainchain,
) async {
  await mainchain.initBinary(
    context,
  );
  log.i('mainchain init: started node, waiting for ibd');
  await mainchain.waitForIBD();

  log.i('mainchain init: successfully started node blocks=${mainchain.blockCount}');
}

Future<void> initEnforcer(
  BuildContext context,
  Logger log,
) async {
  final enforcer = GetIt.I.get<EnforcerRPC>();

  try {
    await enforcer.initBinary(context);
  } catch (e) {
    log.e('could not init enforcer: $e');
  }

  // return when the enforcer is connected, but always move on
  // if 60 seconds have passed
  await Future.any([
    () async {
      while (!enforcer.connected) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }(),
    Future.delayed(const Duration(seconds: 60)),
  ]);

  log.i('mainchain init: successfully started enforcer');
}

Future<void> initBitwindow(
  BuildContext context,
  Logger log,
) async {
  final server = GetIt.I.get<BitwindowRPC>();

  await server.initBinary(context);

  // return when the server is connected, but always move on
  // if 60 seconds have passed
  await Future.any([
    () async {
      while (!server.connected) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }(),
    Future.delayed(const Duration(seconds: 60)),
  ]);

  log.i('server init: successfully started');
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
