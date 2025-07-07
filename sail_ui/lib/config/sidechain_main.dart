import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.dart';
import 'package:sail_ui/sail_ui.dart';

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initSidechainDependencies({
  required Binary sidechain,
  required Future<SidechainRPC> Function(Binary) createSidechainConnection,
  required Directory applicationDir,
  required KeyValueStore store,
  required Logger log,
}) async {
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
  final binaries = await _loadBinaries(applicationDir, sidechain);
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

  final binary = binaries.firstWhere((b) => b.name == sidechain.name);
  final sidechainConnection = await createSidechainConnection(binary);

  GetIt.I.registerSingleton<SidechainRPC>(sidechainConnection);

  // After RPCs including sidechain rpcs have been registered, register the binary provider
  final binaryProvider = BinaryProvider(
    appDir: applicationDir,
    initialBinaries: binaries,
  );
  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );
  bootBinaries(log, sidechain);

  GetIt.I.registerLazySingleton<BMMProvider>(() => BMMProvider());

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => BalanceProvider(
      connections: [sidechainConnection],
    ),
  );

  GetIt.I.registerLazySingleton<AddressProvider>(
    () => AddressProvider(),
  );

  final syncProvider = SyncProvider(
    additionalConnection: SyncConnection(
      rpc: sidechainConnection,
      name: sidechainConnection.binary.name,
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

Future<File> getLogFile(Directory appDir) async {
  try {
    await appDir.create(recursive: true);
  } catch (error) {
    debugPrint('Failed to create appdir: $error');
  }

  final path = [appDir.path, 'debug.log'].join(Platform.pathSeparator);
  final logFile = File(path);

  return logFile;
}

void bootBinaries(Logger log, Binary sidechain) async {
  final BinaryProvider binaryProvider = GetIt.I.get<BinaryProvider>();

  await binaryProvider.startWithEnforcer(
    sidechain,
  );
}

Future<List<Binary>> _loadBinaries(Directory appDir, Binary sidechain) async {
  // Register all binaries
  var binaries = [
    BitcoinCore(),
    Enforcer(),
    sidechain,
  ];

  // make bitassets boot in headless-mode
  binaries[2].addBootArg('--headless');

  return await loadBinaryCreationTimestamp(binaries, appDir);
}
