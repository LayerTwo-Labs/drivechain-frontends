import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/pages/router.dart';
import 'package:sidechain_core/providers/price_provider.dart';
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
    GetIt.I.registerLazySingleton<NotificationProvider>(() => NotificationProvider());
  }

  final store = await KeyValueStore.create(dir: applicationDir);
  final clientSettings = ClientSettings(store: store, log: log);
  if (!GetIt.I.isRegistered<ClientSettings>()) {
    GetIt.I.registerLazySingleton<ClientSettings>(() => clientSettings);
  }

  final bitwindowDir = Directory(path.join(applicationDir.parent.path, 'bitwindow'));
  await bitwindowDir.create(recursive: true);
  LocalAuth.configure(bitwindowDir);
  final bitwindowStore = await KeyValueStore.create(dir: bitwindowDir);
  final bitwindowClientSettings = BitwindowClientSettings(store: bitwindowStore, log: log);
  if (!GetIt.I.isRegistered<BitwindowClientSettings>()) {
    GetIt.I.registerLazySingleton<BitwindowClientSettings>(() => bitwindowClientSettings);
  }

  final settingsProvider = await SettingsProvider.create();
  if (!GetIt.I.isRegistered<SettingsProvider>()) {
    GetIt.I.registerLazySingleton<SettingsProvider>(() => settingsProvider);
  }
  if (!GetIt.I.isRegistered<FormatterProvider>()) {
    GetIt.I.registerLazySingleton<FormatterProvider>(() => FormatterProvider(settingsProvider));
  }

  // Register WalletReaderProvider pointing to bitwindow directory.
  // init() is deferred to bootBackendManagedSidechain — the seed call
  // requires OrchestratorRPC, which standalone sidechain launches register
  // only after drivechaind is up.
  final walletReader = WalletReaderProvider(bitwindowDir);
  if (!GetIt.I.isRegistered<WalletReaderProvider>()) {
    GetIt.I.registerLazySingleton<WalletReaderProvider>(() => walletReader);
  }

  // Register WalletWriterProvider (same code as BitWindow) for chain-agnostic wallet creation
  final walletWriterAlreadyRegistered = GetIt.I.isRegistered<WalletWriterProvider>();
  final walletWriter = walletWriterAlreadyRegistered
      ? GetIt.I.get<WalletWriterProvider>()
      : WalletWriterProvider(bitwindowAppDir: bitwindowDir);
  if (!walletWriterAlreadyRegistered) {
    GetIt.I.registerLazySingleton<WalletWriterProvider>(() => walletWriter);
    await walletWriter.init();
  }

  // Initialize BitcoinConfProvider eagerly to load config before UI renders
  BitcoinConfProvider.promptForDataDir = promptForBitcoinDataDir;
  final bitcoinConfProvider = await BitcoinConfProvider.create(router);
  if (!GetIt.I.isRegistered<BitcoinConfProvider>()) {
    GetIt.I.registerLazySingleton<BitcoinConfProvider>(() => bitcoinConfProvider);
  }

  // Initialize EnforcerConfProvider (must be after BitcoinConfProvider)
  final enforcerConfProvider = await EnforcerConfProvider.create();
  if (!GetIt.I.isRegistered<EnforcerConfProvider>()) {
    GetIt.I.registerLazySingleton<EnforcerConfProvider>(() => enforcerConfProvider);
  }

  // Load paranoid mode from bitwindow settings before creating chains config
  final bitwindowSettingValue = BitwindowSettingValue();
  final loadedBitwindowSetting = await bitwindowClientSettings.getValue(bitwindowSettingValue);
  final paranoidMode = loadedBitwindowSetting.value.paranoidMode;

  // Load chains config from shared bitwindow directory (single source of truth)
  final chainsConfigProvider = await ChainsConfigProvider.create(appDir: bitwindowDir, paranoidMode: paranoidMode);
  if (!GetIt.I.isRegistered<ChainsConfigProvider>()) {
    GetIt.I.registerSingleton<ChainsConfigProvider>(chainsConfigProvider);
  }

  // first of all, write all binaries to the assets/bin directory
  await copyBinariesFromAssets(log, applicationDir);

  // Register LogProvider for process output capture
  if (!GetIt.I.isRegistered<LogProvider>()) {
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
  }

  Binary.isSidechainApp = true;

  // Load and register initial binary states
  final binaries = _initialBinaries(sidechainType, additionalBinaries(), chainsConfigProvider);
  final binaryProvider = GetIt.I.isRegistered<BinaryProvider>()
      ? GetIt.I.get<BinaryProvider>()
      : await BinaryProvider.create(appDir: applicationDir, initialBinaries: binaries, isSidechainApp: true);
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
  // Enforcer traffic funnels through drivechaind's bridge — sidechain
  // apps never dial the enforcer directly.
  final enforcer = GetIt.I.isRegistered<EnforcerRPC>()
      ? GetIt.I.get<EnforcerRPC>()
      : EnforcerLive(host: OrchestratorEndpoint.host, port: OrchestratorEndpoint.port);
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
      OrchestratorRPC(host: OrchestratorEndpoint.host, port: OrchestratorEndpoint.port),
    );
  }

  // The node mode decides which daemons this install runs. bitwindow registers
  // the same provider, so both read one answer.
  registerNodeMode();

  // Binary lifecycle is managed by the backend (e.g. drivechaind).
  // State flows through BackendStateProvider.startWatching() → 1s
  // listBinaries poll → RPCConnection.

  if (!GetIt.I.isRegistered<SidechainBMMProvider>()) {
    GetIt.I.registerLazySingleton<SidechainBMMProvider>(() => SidechainBMMProvider());
  }
  if (!GetIt.I.isRegistered<AppRouter>()) {
    GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());
  }
  if (!GetIt.I.isRegistered<SidechainBalanceProvider>()) {
    GetIt.I.registerLazySingleton<SidechainBalanceProvider>(
      () => SidechainBalanceProvider(sidechain: sidechainConnection),
    );
  }
  if (!GetIt.I.isRegistered<BalanceProvider>()) {
    GetIt.I.registerLazySingleton<BalanceProvider>(() => GetIt.I.get<SidechainBalanceProvider>());
  }
  if (!GetIt.I.isRegistered<AddressProvider>()) {
    GetIt.I.registerLazySingleton<AddressProvider>(() => AddressProvider());
  }
  final syncProvider = GetIt.I.isRegistered<SyncProvider>()
      ? GetIt.I.get<SyncProvider>()
      : SyncProvider(
          additionalConnection: SyncConnection(rpc: sidechainConnection, name: sidechainConnection.chain.name),
        );
  if (!GetIt.I.isRegistered<SyncProvider>()) {
    GetIt.I.registerLazySingleton<SyncProvider>(() => syncProvider);
  }
  unawaited(syncProvider.fetch());
  if (!GetIt.I.isRegistered<DownloadProvider>()) {
    GetIt.I.registerLazySingleton<DownloadProvider>(() => DownloadProvider());
  }
  if (!GetIt.I.isRegistered<SidechainTransactionsProvider>()) {
    GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(() => SidechainTransactionsProvider());
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
  return prepareLogFile(appDir, 'debug.log');
}

List<Binary> _noAdditionalBinaries() => [];

List<Binary> _initialBinaries(BinaryType sidechainType, List<Binary> additional, ChainsConfigProvider configProvider) {
  final configBinaries = configProvider.buildBinaries();

  Binary resolve(BinaryType type) {
    return configBinaries.firstWhere((b) => b.type == type, orElse: () => defaultBinaryFor(type));
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

/// Embedded binaries that ship in one folder per arch on macOS
/// (`macos-arm64` / `macos-x86_64`); the host-arch one is selected at launch.
const _perArchDaemons = {'bitwindowd', 'drivechaind', 'drivechain-cli', 'hwi-daemon'};

/// The asset path to load from the bundle for [canonical]. On macOS the
/// embedded daemons ship per-arch, so the host [arch] folder is prepended;
/// everywhere else there is a single binary under the canonical name.
String embeddedAssetName(String canonical, {required bool isMacOS, required String arch}) =>
    isMacOS && _perArchDaemons.contains(canonical) ? 'macos-$arch/$canonical' : canonical;

Future<void> copyBinariesFromAssets(Logger log, Directory appDir, {OnStaged? onStaged}) =>
    stageEmbeddedBinaries(log, embeddedBinDir(), binDir(appDir.path), onStaged: onStaged);

/// The assets/bin directory of the Flutter assets in the app bundle.
Directory embeddedBinDir() {
  final exeDir = path.dirname(Platform.resolvedExecutable);
  final flutterAssets = Platform.isMacOS
      ? path.join(exeDir, '..', 'Frameworks', 'App.framework', 'Resources', 'flutter_assets')
      : path.join(exeDir, 'data', 'flutter_assets');
  return Directory(path.normalize(path.join(flutterAssets, 'assets', 'bin')));
}

/// Called with the canonical name and the file of each binary that a stage wrote.
typedef OnStaged = void Function(String canonical, File file);

/// Stages the embedded binaries from [sourceDir] in [fileDir]. With [link]
/// (the default on macOS), each one is a symlink to the bundle file, else a
/// copy. A binary that is already staged from the same bundle file stays.
Future<void> stageEmbeddedBinaries(
  Logger log,
  Directory sourceDir,
  Directory fileDir, {
  OnStaged? onStaged,
  bool? link,
}) async {
  await fileDir.create(recursive: true);
  await removeAsideBinaries(fileDir);
  final useLink = link ?? Platform.isMacOS;

  for (final binary in allBinaries) {
    await _copyEmbeddedBinary(
      log,
      sourceDir,
      fileDir,
      binary.binary,
      label: binary.name,
      onStaged: onStaged,
      link: useLink,
    );
  }
  // drivechain-cli is a CLI (not a launchable Binary in allBinaries), but the
  // console execs it from bin/, so it has to be staged here too.
  await _copyEmbeddedBinary(log, sourceDir, fileDir, 'drivechain-cli', onStaged: onStaged, link: useLink);
  // hwi-daemon is the bundled hardware-wallet process.
  await _copyEmbeddedBinary(log, sourceDir, fileDir, 'hwi-daemon', onStaged: onStaged, link: useLink);

  log.d('Finished copying all available binaries to assets/bin');
}

const _asideSuffix = '.old';

/// Deletes the binaries [stageBinary] moved aside. A binary that still runs
/// stays until a later start.
Future<void> removeAsideBinaries(Directory dir) async {
  await for (final entry in dir.list()) {
    if (entry is! File || !entry.path.endsWith(_asideSuffix)) {
      continue;
    }
    try {
      await entry.delete();
    } on FileSystemException {
      continue;
    }
  }
}

/// Copies [source] to [dest] as an executable, through a temp file and a rename.
/// With [moveAside], the old file moves to a `.old` name first.
Future<void> stageBinary(File dest, File source, {bool? moveAside}) async {
  // A shared temp name lets one writer rename a file another still writes,
  // which stages a torn binary. Two app instances share no pid, and two
  // sub-window engines of one instance share no token.
  final token = Random.secure().nextInt(1 << 32).toRadixString(16);
  final staged = File('${dest.path}.$pid-$token.new');
  try {
    final out = await staged.open(mode: FileMode.write);
    try {
      await for (final chunk in source.openRead()) {
        await out.writeFrom(chunk);
      }
      await out.flush();
    } finally {
      await out.close();
    }

    // bitwindowd spawns drivechaind through Go's exec.Command, which does not chmod.
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', staged.path]);
    }

    // Windows refuses a rename over a running .exe, but it permits a rename of it.
    File? aside;
    if ((moveAside ?? Platform.isWindows) && await dest.exists()) {
      aside = await dest.rename('${dest.path}.$pid-$token$_asideSuffix');
    }

    // A second app instance stages binaries that the first one still runs. An
    // in-place overwrite makes macOS kill the running daemon with SIGKILL.
    try {
      await staged.rename(dest.path);
    } catch (_) {
      await aside?.rename(dest.path);
      rethrow;
    }
  } catch (_) {
    if (await staged.exists()) {
      await staged.delete();
    }
    rethrow;
  }
}

/// Points [dest] at [source] with a symlink, through a temp link and a rename.
Future<void> linkBinary(File dest, File source) async {
  final token = Random.secure().nextInt(1 << 32).toRadixString(16);
  final staged = Link('${dest.path}.$pid-$token.new');
  await staged.create(source.absolute.path);
  try {
    await staged.rename(dest.path);
  } catch (_) {
    await staged.delete();
    rethrow;
  }
}

/// True when [file] is a symlink to [source].
Future<bool> _isLinkedTo(File file, File source) async {
  final link = Link(file.path);
  return await link.exists() && await link.target() == source.absolute.path;
}

const _stampSuffix = '.stamp';

/// True when [file] holds the bundle file that [stamp] names as [want].
Future<bool> _isStaged(File file, File stamp, int size, String want) async {
  if (!await stamp.exists() || !await file.exists()) {
    return false;
  }
  return await file.length() == size && await stamp.readAsString() == want;
}

Future<void> _copyEmbeddedBinary(
  Logger log,
  Directory sourceDir,
  Directory fileDir,
  String canonical, {
  String? label,
  OnStaged? onStaged,
  required bool link,
}) async {
  final name = label ?? canonical;
  final exe = Platform.isWindows && !canonical.endsWith('.exe') ? '.exe' : '';
  final destName = '$canonical$exe';
  final assetName = '${embeddedAssetName(canonical, isMacOS: Platform.isMacOS, arch: currentArch())}$exe';

  // Most binaries aren't bundled into assets/bin, only the embedded daemons are.
  final source = File(path.join(sourceDir.path, assetName));
  if (!await source.exists()) {
    return;
  }

  try {
    final file = File(path.join(fileDir.path, destName));
    final stamp = File('${file.path}$_stampSuffix');
    final sourceStat = await source.stat();
    final want = '${sourceStat.size}:${sourceStat.modified.microsecondsSinceEpoch}';
    if (await _isStaged(file, stamp, sourceStat.size, want) && (!link || await _isLinkedTo(file, source))) {
      return;
    }

    // A link runs the daemon from the signed bundle, so an app update writes no copy.
    if (link) {
      await linkBinary(file, source);
    } else {
      await stageBinary(file, source);
    }
    onStaged?.call(canonical, file);
    await stamp.writeAsString(want, flush: true);

    log.d('Staged binary $name from $assetName at ${file.path}');
  } catch (e) {
    log.w('Failed to copy binary $name: $e');
  }
}

/// Build the full list of binaries, preferring JSON config if available.
List<Binary> get allBinaries => [
  ...coreBinaries,
  ...sidechainBinaries,
  resolveFromConfig(BinaryType.BINARY_TYPE_ZSIDED, () => ZSided()),
];
