import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/env.dart';
import 'package:sail_ui/pages/router.dart';
import 'package:sail_ui/providers/price_provider.dart';
import 'package:sail_ui/sail_ui.dart';

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initSidechainDependencies({
  required BinaryType sidechainType,
  required SidechainRPC Function(Binary) createSidechainConnection,
  required Directory applicationDir,
  required Logger log,
  required RootStackRouter router,
  required String currentVersion,
  List<Binary> Function() additionalBinaries = _noAdditionalBinaries,
  bool backendManagesBinaries = false,
}) async {
  Environment.backendManagesBinaries = backendManagesBinaries;

  GetIt.I.registerLazySingleton<NotificationProvider>(() => NotificationProvider());

  final store = await KeyValueStore.create(dir: applicationDir);
  final clientSettings = ClientSettings(store: store, log: log);
  GetIt.I.registerLazySingleton<ClientSettings>(() => clientSettings);

  final bitwindowDir = Directory(path.join(applicationDir.parent.path, 'bitwindow'));
  final bitwindowStore = await KeyValueStore.create(dir: bitwindowDir);
  final bitwindowClientSettings = BitwindowClientSettings(store: bitwindowStore, log: log);
  GetIt.I.registerLazySingleton<BitwindowClientSettings>(() => bitwindowClientSettings);

  // Register WalletReaderProvider pointing to bitwindow directory
  final walletReader = WalletReaderProvider.create(bitwindowDir);
  GetIt.I.registerLazySingleton<WalletReaderProvider>(() => walletReader);
  await walletReader.init();

  // Register WalletWriterProvider (same code as BitWindow) for chain-agnostic wallet creation
  final walletWriter = WalletWriterProvider.create(bitwindowAppDir: bitwindowDir);
  GetIt.I.registerLazySingleton<WalletWriterProvider>(() => walletWriter);
  await walletWriter.init();

  final settingsProvider = await SettingsProvider.create();
  GetIt.I.registerLazySingleton<SettingsProvider>(() => settingsProvider);
  GetIt.I.registerLazySingleton<FormatterProvider>(() => FormatterProvider(settingsProvider));

  // Initialize BitcoinConfProvider eagerly to load config before UI renders
  final bitcoinConfProvider = await BitcoinConfProvider.create(router);
  GetIt.I.registerLazySingleton<BitcoinConfProvider>(() => bitcoinConfProvider);

  // Initialize EnforcerConfProvider (must be after BitcoinConfProvider)
  final enforcerConfProvider = await EnforcerConfProvider.create();
  GetIt.I.registerLazySingleton<EnforcerConfProvider>(() => enforcerConfProvider);

  // Load chains config from shared bitwindow directory (single source of truth)
  final chainsConfigProvider = await ChainsConfigProvider.create(appDir: bitwindowDir);
  GetIt.I.registerSingleton<ChainsConfigProvider>(chainsConfigProvider);

  // first of all, write all binaries to the assets/bin directory
  await copyBinariesFromAssets(log, applicationDir);

  // Register LogProvider for process output capture
  GetIt.I.registerSingleton<LogProvider>(LogProvider());

  // Load and register initial binary states
  final binaries = _initialBinaries(sidechainType, additionalBinaries(), chainsConfigProvider);
  final binaryProvider = await BinaryProvider.create(appDir: applicationDir, initialBinaries: binaries);
  GetIt.I.registerSingleton<BinaryProvider>(binaryProvider);

  // register and boot binaries
  final mainchainRPC = MainchainRPCLive.create();
  GetIt.I.registerLazySingleton<MainchainRPC>(() => mainchainRPC);
  final enforcer = EnforcerLive();
  GetIt.I.registerSingleton<EnforcerRPC>(enforcer);
  final binary = binaries.firstWhere((b) => b.type == sidechainType);
  final sidechainConnection = createSidechainConnection(binary);
  GetIt.I.registerSingleton<SidechainRPC>(sidechainConnection);

  // Boot binaries (skip if a backend server like thunderd manages them)
  if (!backendManagesBinaries) {
    bootBinaries(log, binary);
  } else {
    // Backend manages binaries — just start connection timers so the UI
    // can detect when the backend brings services online.
    startConnectionTimersOnly(log);
  }

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
  GetIt.I.registerLazySingleton<PriceProvider>(() => PriceProvider());

  // Register UpdateProvider for checking updates
  GetIt.I.registerSingleton<UpdateProvider>(
    UpdateProvider(
      log: log,
      binaryType: sidechainType,
      currentVersion: currentVersion,
    ),
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

  // Download grpcurl in background (needed for enforcer-cli in console)
  final grpcurl = binaryProvider.binaries.firstWhere((b) => b is GRPCurl);
  unawaited(() async {
    try {
      log.i('Downloading grpcurl in background');
      await binaryProvider.download(grpcurl, shouldUpdate: true);
      log.i('grpcurl download complete');
    } catch (e) {
      log.w('Failed to download grpcurl: $e');
    }
  }());

  await binaryProvider.startWithEnforcer(sidechain);
}

void startConnectionTimersOnly(Logger log) {
  final mainchainRPC = GetIt.I.get<MainchainRPC>();
  final enforcerRPC = GetIt.I.get<EnforcerRPC>();
  final sidechainRPC = GetIt.I.get<SidechainRPC>();

  log.i('Backend manages binaries — starting connection timers only (no process boot)');

  mainchainRPC.startConnectionTimer();
  enforcerRPC.startConnectionTimer();
  sidechainRPC.startConnectionTimer();
}

List<Binary> _noAdditionalBinaries() => [];

List<Binary> _initialBinaries(BinaryType sidechainType, List<Binary> additional, ChainsConfigProvider configProvider) {
  final configBinaries = configProvider.buildBinaries();

  Binary resolve(BinaryType type) {
    return configBinaries.firstWhere(
      (b) => b.type == type,
      orElse: () => type.binary, // fall back to hardcoded defaults
    );
  }

  final sidechain = resolve(sidechainType);
  var binaries = [
    resolve(BinaryType.bitcoinCore),
    resolve(BinaryType.enforcer),
    resolve(BinaryType.grpcurl),
    sidechain,
    ...additional,
  ];

  // make sidechain boot in headless mode
  binaries[3].addBootArg('--headless');

  return binaries;
}

Future<void> copyBinariesFromAssets(Logger log, Directory appDir) async {
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

/// Build the full list of binaries, preferring JSON config if available.
List<Binary> get allBinaries => [
  ...coreBinaries,
  ...sidechainBinaries,
  resolveFromConfig(BinaryType.thunderd, () => Thunderd()),
  resolveFromConfig(BinaryType.zSided, () => ZSided()),
];

List<Binary> get coreBinaries => [
  resolveFromConfig(BinaryType.bitcoinCore, () => BitcoinCore()),
  resolveFromConfig(BinaryType.enforcer, () => Enforcer()),
  resolveFromConfig(BinaryType.bitWindow, () => BitWindow()),
];

List<Binary> get sidechainBinaries => [
  resolveFromConfig(BinaryType.thunder, () => Thunder()),
  resolveFromConfig(BinaryType.truthcoin, () => Truthcoin()),
  resolveFromConfig(BinaryType.photon, () => Photon()),
  resolveFromConfig(BinaryType.bitnames, () => BitNames()),
  resolveFromConfig(BinaryType.bitassets, () => BitAssets()),
  resolveFromConfig(BinaryType.coinShift, () => CoinShift()),
  resolveFromConfig(BinaryType.zSide, () => ZSide()),
];

Binary resolveFromConfig(BinaryType type, Binary Function() fallback) {
  if (GetIt.I.isRegistered<ChainsConfigProvider>()) {
    final configProvider = GetIt.I.get<ChainsConfigProvider>();
    final binary = configProvider.buildBinaryByType(type);
    if (binary != null) return binary;
  }
  return fallback();
}
