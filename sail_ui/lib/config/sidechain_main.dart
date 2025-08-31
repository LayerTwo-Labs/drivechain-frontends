import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/pages/router.dart';
import 'package:sail_ui/sail_ui.dart';

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initSidechainDependencies({
  required BinaryType sidechainType,
  required Future<SidechainRPC> Function(Binary) createSidechainConnection,
  required Directory applicationDir,
  required KeyValueStore store,
  required Logger log,
}) async {
  GetIt.I.registerLazySingleton<NotificationProvider>(() => NotificationProvider());

  final clientSettings = ClientSettings(store: store, log: log);
  GetIt.I.registerLazySingleton<ClientSettings>(() => clientSettings);
  final settingsProvider = await SettingsProvider.create();
  GetIt.I.registerLazySingleton<SettingsProvider>(() => settingsProvider);

  // first of all, write all binaries to the assets/bin directory
  await copyBinariesFromAssets(log, applicationDir);

  // Load and register initial binary states
  final binaries = _initialBinaries(sidechainType.binary);
  final binaryProvider = await BinaryProvider.create(appDir: applicationDir, initialBinaries: binaries);
  GetIt.I.registerSingleton<BinaryProvider>(binaryProvider);

  // register and boot binaries
  final mainchainRPC = MainchainRPCLive();
  GetIt.I.registerLazySingleton<MainchainRPC>(() => mainchainRPC);
  final enforcer = EnforcerLive();
  GetIt.I.registerSingleton<EnforcerRPC>(enforcer);
  final binary = binaries.firstWhere((b) => b.type == sidechainType);
  final sidechainConnection = await createSidechainConnection(binary);
  GetIt.I.registerSingleton<SidechainRPC>(sidechainConnection);
  bootBinaries(log, binary);

  GetIt.I.registerLazySingleton<BMMProvider>(() => BMMProvider());
  GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());
  GetIt.I.registerLazySingleton<BalanceProvider>(() => BalanceProvider(connections: [sidechainConnection]));
  GetIt.I.registerLazySingleton<AddressProvider>(() => AddressProvider());
  final syncProvider = SyncProvider(
    additionalConnection: SyncConnection(rpc: sidechainConnection, name: sidechainConnection.chain.name),
  );
  GetIt.I.registerLazySingleton<SyncProvider>(() => syncProvider);
  unawaited(syncProvider.fetch());
  GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(() => SidechainTransactionsProvider());
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

  await binaryProvider.startWithEnforcer(sidechain);
}

List<Binary> _initialBinaries(Binary sidechain) {
  // Register all binaries
  var binaries = [BitcoinCore(), Enforcer(), sidechain];

  // make sidechain boot in headless-mode
  binaries[2].addBootArg('--headless');

  return binaries;
}

Future<void> copyBinariesFromAssets(Logger log, Directory appDir) async {
  final allBinaries = [BitcoinCore(), Enforcer(), BitWindow(), Thunder(), Bitnames(), BitAssets(), ZSide()];

  final fileDir = binDir(appDir.path);
  await fileDir.create(recursive: true);

  for (final binary in allBinaries) {
    try {
      final binaryName = binary.binary + (Platform.isWindows && !binary.binary.endsWith('.exe') ? '.exe' : '');
      final assetPath = 'assets/bin/$binaryName';

      final binResource = await rootBundle.load(assetPath);
      final file = File(path.join(fileDir.path, binaryName));

      log.d('Writing binary ${binary.name} to: ${file.path}');

      final buffer = binResource.buffer;
      await file.writeAsBytes(buffer.asUint8List(binResource.offsetInBytes, binResource.lengthInBytes));

      log.d('Successfully wrote binary: ${binary.name}');
    } catch (e) {
      log.w('Failed to copy binary ${binary.name}: $e');
      // It's fine to fail, probably just doesn't exist in the assets/bin directory
    }
  }

  log.d('Finished copying all available binaries to assets/bin');
}
