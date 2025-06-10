import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/env.dart';
import 'package:launcher/providers/quotes_provider.dart';
import 'package:launcher/routing/router.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final log = Logger();
  await initDependencies(log);

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(400, 400),
    size: Size(1200, 600),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Drivechain Launcher',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  final router = GetIt.I.get<AppRouter>();

  return runApp(
    ChangeNotifierProvider(
      create: (_) => GetIt.I.get<QuotesProvider>(),
      child: SailApp(
        dense: true,
        builder: (context) {
          return MaterialApp.router(
            routerDelegate: router.delegate(),
            routeInformationParser: router.defaultRouteParser(),
            title: 'Drivechain Launcher',
            builder: (context, child) => child ?? const SizedBox(),
            theme: ThemeData(
              visualDensity: VisualDensity.compact,
              fontFamily: 'Inter',
            ),
          );
        },
        accentColor: const Color.fromARGB(255, 255, 153, 0),
        log: log,
      ),
    ),
  );
}

Future<void> initDependencies(Logger log) async {
  final storage = await KeyValueStore.create();

  // Register the logger
  GetIt.I.registerLazySingleton<Logger>(() => log);

  // Register the router
  GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());

  // Needed for sail_ui to work
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: storage,
      log: log,
    ),
  );

  final appDir = await Environment.appDir();
  final processProvider = ProcessProvider(
    appDir: appDir,
  );
  GetIt.I.registerSingleton<ProcessProvider>(
    processProvider,
  );

  // Load initial binary states
  final binaries = await _loadBinaries(appDir);

  // Register all RPCs in GetIt
  await Future.wait(
    binaries.map((binary) async {
      switch (binary) {
        case ParentChain():
          final mainchain = await MainchainRPCLive.create(binary);
          GetIt.I.registerSingleton<MainchainRPC>(mainchain);

        case Enforcer():
          final enforcer = await EnforcerLive.create(
            host: '127.0.0.1',
            port: binary.port,
            binary: binary,
            launcherAppDir: appDir,
          );
          GetIt.I.registerSingleton<EnforcerRPC>(enforcer);

        case BitWindow():
          final bitwindow = await BitwindowRPCLive.create(
            host: '127.0.0.1',
            port: binary.port,
            binary: binary,
          );
          GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);

        case Thunder():
          final thunder = await ThunderLive.create(
            binary: binary,
            chain: Sidechain.fromBinary(binary),
          );
          GetIt.I.registerSingleton<ThunderRPC>(thunder);

        case Bitnames():
          final bitnames = await BitnamesLive.create(
            binary: binary,
            chain: Sidechain.fromBinary(binary),
          );
          GetIt.I.registerSingleton<BitnamesRPC>(bitnames);

        case BitAssets():
          final bitassets = await BitAssetsLive.create(
            binary: binary,
            chain: Sidechain.fromBinary(binary),
          );
          GetIt.I.registerSingleton<BitAssetsRPC>(bitassets);
      }
    }),
  );

  final binaryProvider = BinaryProvider(
    appDir: await Environment.appDir(),
    initialBinaries: binaries,
  );
  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );

  final blockInfoProvider = SyncProgressProvider();
  GetIt.I.registerLazySingleton<SyncProgressProvider>(
    () => blockInfoProvider,
  );
  unawaited(blockInfoProvider.fetch());

  // Register quotes provider
  GetIt.I.registerSingleton<QuotesProvider>(
    QuotesProvider(storage),
  );

  // Register wallet service
  GetIt.I.registerSingleton<WalletService>(WalletService());
}

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  var binaries = [
    ParentChain(),
    Enforcer(),
    BitWindow(),
    Thunder(),
    Bitnames(),
    BitAssets(),
  ];

  return await loadBinaryCreationTimestamp(binaries, appDir);
}
