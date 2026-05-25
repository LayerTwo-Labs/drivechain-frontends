import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
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
}) async {
  if (!GetIt.I.isRegistered<NotificationProvider>()) {
    GetIt.I.registerLazySingleton<NotificationProvider>(
      () => NotificationProvider(),
    );
  }

  final store = await KeyValueStore.create(dir: applicationDir);
  final clientSettings = ClientSettings(store: store, log: log);
  if (!GetIt.I.isRegistered<ClientSettings>()) {
    GetIt.I.registerLazySingleton<ClientSettings>(() => clientSettings);
  }

  final bitwindowDir = Directory(
    path.join(applicationDir.parent.path, 'bitwindow'),
  );
  await bitwindowDir.create(recursive: true);
  final bitwindowStore = await KeyValueStore.create(dir: bitwindowDir);
  final bitwindowClientSettings = BitwindowClientSettings(
    store: bitwindowStore,
    log: log,
  );
  if (!GetIt.I.isRegistered<BitwindowClientSettings>()) {
    GetIt.I.registerLazySingleton<BitwindowClientSettings>(
      () => bitwindowClientSettings,
    );
  }

  final settingsProvider = await SettingsProvider.create();
  if (!GetIt.I.isRegistered<SettingsProvider>()) {
    GetIt.I.registerLazySingleton<SettingsProvider>(() => settingsProvider);
  }
  if (!GetIt.I.isRegistered<FormatterProvider>()) {
    GetIt.I.registerLazySingleton<FormatterProvider>(
      () => FormatterProvider(settingsProvider),
    );
  }

  // Register WalletReaderProvider pointing to bitwindow directory.
  // init() is deferred to bootBackendManagedSidechain — the seed call
  // requires OrchestratorRPC, which standalone sidechain launches register
  // only after orchestratord is up.
  final walletReader = WalletReaderProvider(bitwindowDir);
  if (!GetIt.I.isRegistered<WalletReaderProvider>()) {
    GetIt.I.registerLazySingleton<WalletReaderProvider>(() => walletReader);
  }

  // Register WalletWriterProvider (same code as BitWindow) for chain-agnostic wallet creation
  final walletWriterAlreadyRegistered = GetIt.I.isRegistered<WalletWriterProvider>();
  final walletWriter = walletWriterAlreadyRegistered
      ? GetIt.I.get<WalletWriterProvider>()
      : WalletWriterProvider(
          bitwindowAppDir: bitwindowDir,
        );
  if (!walletWriterAlreadyRegistered) {
    GetIt.I.registerLazySingleton<WalletWriterProvider>(() => walletWriter);
    await walletWriter.init();
  }

  // Initialize BitcoinConfProvider eagerly to load config before UI renders
  final bitcoinConfProvider = await BitcoinConfProvider.create(router);
  if (!GetIt.I.isRegistered<BitcoinConfProvider>()) {
    GetIt.I.registerLazySingleton<BitcoinConfProvider>(() => bitcoinConfProvider);
  }

  // Initialize EnforcerConfProvider (must be after BitcoinConfProvider)
  final enforcerConfProvider = await EnforcerConfProvider.create();
  if (!GetIt.I.isRegistered<EnforcerConfProvider>()) {
    GetIt.I.registerLazySingleton<EnforcerConfProvider>(
      () => enforcerConfProvider,
    );
  }

  // Load paranoid mode from bitwindow settings before creating chains config
  final bitwindowSettingValue = BitwindowSettingValue();
  final loadedBitwindowSetting = await bitwindowClientSettings.getValue(
    bitwindowSettingValue,
  );
  final paranoidMode = loadedBitwindowSetting.value.paranoidMode;

  // Load chains config from shared bitwindow directory (single source of truth)
  final chainsConfigProvider = await ChainsConfigProvider.create(
    appDir: bitwindowDir,
    paranoidMode: paranoidMode,
  );
  if (!GetIt.I.isRegistered<ChainsConfigProvider>()) {
    GetIt.I.registerSingleton<ChainsConfigProvider>(chainsConfigProvider);
  }

  // first of all, write all binaries to the assets/bin directory
  await copyBinariesFromAssets(log, applicationDir);

  // Register LogProvider for process output capture
  if (!GetIt.I.isRegistered<LogProvider>()) {
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
  }

  // Load and register initial binary states
  final binaries = _initialBinaries(
    sidechainType,
    additionalBinaries(),
    chainsConfigProvider,
  );
  final binaryProvider = GetIt.I.isRegistered<BinaryProvider>()
      ? GetIt.I.get<BinaryProvider>()
      : await BinaryProvider.create(
          appDir: applicationDir,
          initialBinaries: binaries,
          isSidechainApp: true,
        );
  if (!GetIt.I.isRegistered<BinaryProvider>()) {
    GetIt.I.registerSingleton<BinaryProvider>(binaryProvider);
  }

  // register and boot binaries
  final mainchainRPC = GetIt.I.isRegistered<BitcoindConnection>()
      ? GetIt.I.get<BitcoindConnection>()
      : BitcoindConnection();
  if (!GetIt.I.isRegistered<BitcoindConnection>()) {
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => mainchainRPC);
  }
  final enforcer = GetIt.I.isRegistered<EnforcerRPC>() ? GetIt.I.get<EnforcerRPC>() : EnforcerLive();
  if (!GetIt.I.isRegistered<EnforcerRPC>()) {
    GetIt.I.registerSingleton<EnforcerRPC>(enforcer);
  }
  final binary = binaryProvider.binaries.firstWhere(
    (b) => b.type == sidechainType,
    orElse: () => binaries.firstWhere((b) => b.type == sidechainType),
  );
  final sidechainConnection = createSidechainConnection(binary);
  if (!GetIt.I.isRegistered<SidechainRPC>()) {
    GetIt.I.registerSingleton<SidechainRPC>(sidechainConnection);
  }

  // Register OrchestratorRPC before SyncProvider — the constructor just holds
  // host/port, the connection dial is lazy. SyncProvider.fetch() runs from its
  // own constructor and needs this resolvable before initBackendManagedSidechainRuntime
  // runs. initBackendManagedSidechainRuntime guards against double-registration.
  if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
    GetIt.I.registerSingleton<OrchestratorRPC>(
      OrchestratorRPC(host: 'localhost', port: 30400),
    );
  }

  // Binary lifecycle is managed by the backend (e.g. orchestratord).
  // State flows through BackendStateProvider.startWatching() → 1s
  // listBinaries poll → RPCConnection.

  if (!GetIt.I.isRegistered<BMMProvider>()) {
    GetIt.I.registerLazySingleton<BMMProvider>(() => BMMProvider());
  }
  if (!GetIt.I.isRegistered<AppRouter>()) {
    GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());
  }
  if (!GetIt.I.isRegistered<BalanceProvider>()) {
    GetIt.I.registerLazySingleton<BalanceProvider>(
      () => BalanceProvider(connections: [sidechainConnection]),
    );
  }
  if (!GetIt.I.isRegistered<AddressProvider>()) {
    GetIt.I.registerLazySingleton<AddressProvider>(() => AddressProvider());
  }
  final syncProvider = GetIt.I.isRegistered<SyncProvider>()
      ? GetIt.I.get<SyncProvider>()
      : SyncProvider(
          additionalConnection: SyncConnection(
            rpc: sidechainConnection,
            name: sidechainConnection.chain.name,
          ),
        );
  if (!GetIt.I.isRegistered<SyncProvider>()) {
    GetIt.I.registerLazySingleton<SyncProvider>(() => syncProvider);
  }
  unawaited(syncProvider.fetch());
  if (!GetIt.I.isRegistered<DownloadProvider>()) {
    GetIt.I.registerLazySingleton<DownloadProvider>(() => DownloadProvider());
  }
  if (!GetIt.I.isRegistered<SidechainTransactionsProvider>()) {
    GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(
      () => SidechainTransactionsProvider(),
    );
  }

  // Refetch on every new mainchain block — without this the UI relies on
  // each provider's own (slower) poll cadence and the user sees stale
  // balance/transactions for up to ~1s after a block lands (#1766). The
  // SyncProvider's onNewBlock broadcast already dedupes on strict height
  // increment, so this only fires when there's actually new data to fetch.
  syncProvider.onNewBlock((_) {
    if (GetIt.I.isRegistered<BalanceProvider>()) {
      unawaited(GetIt.I<BalanceProvider>().fetch());
    }
    if (GetIt.I.isRegistered<SidechainTransactionsProvider>()) {
      unawaited(GetIt.I<SidechainTransactionsProvider>().fetch());
    }
  });
  if (!GetIt.I.isRegistered<PriceProvider>()) {
    GetIt.I.registerLazySingleton<PriceProvider>(() => PriceProvider());
  }

  // Register UpdateProvider for checking updates
  if (!GetIt.I.isRegistered<UpdateProvider>()) {
    GetIt.I.registerSingleton<UpdateProvider>(
      UpdateProvider(
        log: log,
        binaryType: sidechainType,
        currentVersion: currentVersion,
        onBeforeUpdate: () async {
          final binaryProvider = GetIt.I.get<BinaryProvider>();
          await binaryProvider.onShutdown();
        },
      ),
    );
  }
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

List<Binary> _noAdditionalBinaries() => [];

List<Binary> _initialBinaries(
  BinaryType sidechainType,
  List<Binary> additional,
  ChainsConfigProvider configProvider,
) {
  final configBinaries = configProvider.buildBinaries();

  Binary resolve(BinaryType type) {
    return configBinaries.firstWhere(
      (b) => b.type == type,
      orElse: () => defaultBinaryFor(type),
    );
  }

  final sidechain = resolve(sidechainType);
  var binaries = [
    resolve(BinaryType.BINARY_TYPE_BITCOIND),
    resolve(BinaryType.BINARY_TYPE_ENFORCER),
    resolve(BinaryType.BINARY_TYPE_GRPCURL),
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
      await file.writeAsBytes(
        buffer.asUint8List(
          binResource.offsetInBytes,
          binResource.lengthInBytes,
        ),
      );

      // Ensure the copied binary is executable. bitwindowd spawns
      // orchestratord via Go's exec.Command which does NOT chmod, so without
      // this orchestratord fails with "permission denied" on fresh installs.
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', file.path]);
        log.d('chmoded ${file.path}');
      }

      log.d('Successfully wrote binary: ${binary.name}');
    } catch (e) {
      // Most binaries aren't bundled into assets/bin (only bitwindowd and
      // orchestratord are) — Flutter's "Unable to load asset" error is
      // expected for everything else. Silence it; surface anything else.
      if (!e.toString().contains('Unable to load asset')) {
        log.w('Failed to copy binary ${binary.name}: $e');
      }
    }
  }

  log.d('Finished copying all available binaries to assets/bin');
}

/// Build the full list of binaries, preferring JSON config if available.
List<Binary> get allBinaries => [
  ...coreBinaries,
  ...sidechainBinaries,
  resolveFromConfig(BinaryType.BINARY_TYPE_ORCHESTRATORD, () => Orchestratord()),
  resolveFromConfig(BinaryType.BINARY_TYPE_ZSIDED, () => ZSided()),
];

List<Binary> get coreBinaries => [
  resolveFromConfig(BinaryType.BINARY_TYPE_BITCOIND, () => BitcoinCore()),
  resolveFromConfig(BinaryType.BINARY_TYPE_ENFORCER, () => Enforcer()),
  resolveFromConfig(BinaryType.BINARY_TYPE_BITWINDOWD, () => BitWindow()),
  resolveFromConfig(BinaryType.BINARY_TYPE_ORCHESTRATORD, () => Orchestratord()),
];

List<Binary> get sidechainBinaries => [
  resolveFromConfig(BinaryType.BINARY_TYPE_THUNDER, () => Thunder()),
  resolveFromConfig(BinaryType.BINARY_TYPE_TRUTHCOIN, () => Truthcoin()),
  resolveFromConfig(BinaryType.BINARY_TYPE_PHOTON, () => Photon()),
  resolveFromConfig(BinaryType.BINARY_TYPE_BITNAMES, () => BitNames()),
  resolveFromConfig(BinaryType.BINARY_TYPE_BITASSETS, () => BitAssets()),
  resolveFromConfig(BinaryType.BINARY_TYPE_COINSHIFT, () => CoinShift()),
  resolveFromConfig(BinaryType.BINARY_TYPE_ZSIDE, () => ZSide()),
];

Binary resolveFromConfig(BinaryType type, Binary Function() fallback) {
  if (GetIt.I.isRegistered<ChainsConfigProvider>()) {
    final configProvider = GetIt.I.get<ChainsConfigProvider>();
    final binary = configProvider.buildBinaryByType(type);
    if (binary != null) return binary;
  }
  return fallback();
}
