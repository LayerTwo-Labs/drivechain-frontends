import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/env.dart';
import 'package:launcher/providers/quotes_provider.dart';
import 'package:launcher/routing/router.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final log = Logger();
  final router = AppRouter();
  await initDependencies(log);

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(600, 700),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Drivechain Launcher',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

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
  final prefs = await SharedPreferences.getInstance();

  // Register the logger
  GetIt.I.registerLazySingleton<Logger>(() => log);

  // Needed for sidesail_ui to work
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
      log: log,
    ),
  );

  final appDir = await Environment.appDir();
  final processProvider = ProcessProvider(
    datadir: appDir,
  );
  GetIt.I.registerSingleton<ProcessProvider>(
    processProvider,
  );

  // Load initial binary states
  final binaries = await _loadBinaries(appDir);

  // Register all RPCs in GetIt
  for (final binary in binaries) {
    switch (binary) {
      case ParentChain():
        final mainchain = await MainchainRPCLive.create(binary);
        GetIt.I.registerSingleton<MainchainRPC>(mainchain);

      case Enforcer():
        final enforcer = await EnforcerLive.create(
          binary: binary,
          logPath: path.join(binary.datadir(), 'enforcer.log'),
        );
        GetIt.I.registerSingleton<EnforcerRPC>(enforcer);

      case BitWindow():
        final bitwindow = await BitwindowRPCLive.create(
          host: '127.0.0.1',
          port: binary.port,
          binary: binary,
          logPath: path.join(binary.datadir(), 'bitwindow.log'),
        );
        GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);

      case Thunder():
        final thunder = await ThunderLive.create(
          binary: binary,
          logPath: path.join(binary.datadir(), 'thunder.log'),
        );
        GetIt.I.registerSingleton<ThunderRPC>(thunder);

      case Bitnames():
        final bitnames = await BitnamesLive.create(
          binary: binary,
          logPath: path.join(binary.datadir(), 'bitnames.log'),
        );
        GetIt.I.registerSingleton<BitnamesRPC>(bitnames);
    }
  }
  // Register binary provider
  final binaryProvider = BinaryProvider(
    appDir: appDir,
    initialBinaries: binaries,
  );
  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );

  // Register blockchain provider
  GetIt.I.registerSingleton<BlockchainProvider>(
    BlockchainProvider(),
  );

  // Register quotes provider
  GetIt.I.registerSingleton<QuotesProvider>(
    QuotesProvider(prefs),
  );

  // Register services
  GetIt.I.registerLazySingleton<WalletService>(
    () => WalletService(),
  );
}

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  final jsonString = await rootBundle.loadString('assets/chain_config.json');
  final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

  final binaries = (jsonData['chains'] as List<dynamic>?)
          ?.map((chain) => Binary.fromJson(chain as Map<String, dynamic>? ?? {}))
          .toList() ??
      [];

  for (var i = 0; i < binaries.length; i++) {
    final binary = binaries[i];
    try {
      // Check release date from server
      var updatedConfig = binary.download;

      // Load metadata from assets/
      final metadata = await binary.loadMetadata(appDir);

      if (metadata != null) {
        // Update the binary's download config with the downloaded timestamp
        updatedConfig = updatedConfig.copyWith(downloadedTimestamp: metadata.releaseDate);
      }

      // Update binary with all timestamp info
      binaries[i] = binary.copyWith(download: updatedConfig);
    } catch (e) {
      // Log error but continue with other binaries
      GetIt.I.get<Logger>().e('Error loading binary state for ${binary.name}: $e');
    }
  }

  return binaries;
}
