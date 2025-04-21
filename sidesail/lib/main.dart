import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/providers/bmm_provider.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/active_sidechains.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/storage/sail_settings/font_settings.dart';
import 'package:sidesail/storage/sail_settings/network_settings.dart';
import 'package:sidesail/widgets/containers/dropdownactions/console.dart';
import 'package:window_manager/window_manager.dart';

Future<void> start(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory? applicationDir;
  File? logFile;
  String? chainName;

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

  // Fall back to filesystem if not provided in args
  applicationDir ??= await getApplicationSupportDirectory();
  logFile ??= await getLogFile();
  Sidechain chain = Sidechain.fromString(chainName ?? RuntimeArgs.chain) ?? TestSidechain();
  final store = await KeyValueStore.create(dir: applicationDir);

  await initDependencies(chain, applicationDir, logFile, store);

  SidechainContainer sidechain = GetIt.I.get<SidechainContainer>();
  AppRouter router = GetIt.I.get<AppRouter>();
  Logger log = GetIt.I.get<Logger>();

  log.i('starting sidesail with chain: ${chain.name} ${RuntimeArgs.chain}');

  if (args.contains('multi_window')) {
    final arguments = jsonDecode(args[2]) as Map<String, dynamic>;

    Widget child = SailCard(
      child: SailText.primary15('no window type provided, the programmers messed up'),
    );

    switch (arguments['window_type']) {
      case 'console':
        child = const ConsoleWindow();
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
        accentColor: sidechain.rpc.chain.color,
      ),
    );
  }

  final font = (await GetIt.I.get<ClientSettings>().getValue(FontSetting())).value;

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (context) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: chain.name,
        theme: ThemeData(
          fontFamily: font == SailFontValues.sourceCodePro ? 'SourceCodePro' : 'Inter',
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: sidechain.rpc.chain.color),
        ),
      ),

      accentColor: sidechain.rpc.chain.color,
      log: log,
    ),
  );
}

bool isCurrentChainActive({
  required List<ActiveSidechain> activeChains,
  required Binary currentChain,
}) {
  final foundMatch = activeChains.firstWhereOrNull((chain) => chain.title == currentChain.name);
  return foundMatch != null;
}

void main(List<String> args) async {
  // the application is launched function because some startup things
  // are async
  await start(args);
}

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initDependencies(
  Sidechain chain,
  Directory applicationDir,
  File logFile,
  KeyValueStore store,
) async {
  final log = await logger(RuntimeArgs.fileLog, RuntimeArgs.consoleLog, logFile);
  GetIt.I.registerLazySingleton<Logger>(() => log);

  GetIt.I.registerLazySingleton<ProcessProvider>(
    () => ProcessProvider(
      appDir: applicationDir,
    ),
  );

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

  // Load initial binary states
  final binaries = await _loadBinaries(applicationDir);
  // then register any sidechain rpcs
  final sidechain = await findSubRPC(chain, binaries, store: store);
  final sidechainContainer = await SidechainContainer.create(sidechain);
  GetIt.I.registerLazySingleton<SidechainContainer>(
    () => sidechainContainer,
  );

  final mainchainRPC = await MainchainRPCLive.create(
    binaries.firstWhere((b) => b is ParentChain),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );

  final launcherAppDir = Directory(
    path.join(
      applicationDir.path,
      '..',
      'com.layertwolabs.launcher',
    ),
  );
  final enforcerBinary = binaries.firstWhere((b) => b is Enforcer);
  final enforcer = await EnforcerLive.create(
    host: '127.0.0.1',
    port: enforcerBinary.port,
    binary: enforcerBinary,
    launcherAppDir: launcherAppDir,
  );
  GetIt.I.registerSingleton<EnforcerRPC>(enforcer);

  // After RPCs including sidechain rpcs have been registered, register the binary provider
  final binaryProvider = BinaryProvider(
    appDir: applicationDir,
    initialBinaries: binaries,
  );
  GetIt.I.registerSingleton<BinaryProvider>(
    binaryProvider,
  );

  bootBinaries(log);

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => BalanceProvider(
      connections: [sidechain],
    ),
  );

  final blockInfoProvider = BlockInfoProvider(
    additionalConnection: BlockSyncConnection(
      rpc: sidechain,
      name: sidechain.binary.name,
    ),
  );
  GetIt.I.registerLazySingleton<BlockInfoProvider>(
    () => blockInfoProvider,
  );
  unawaited(blockInfoProvider.fetch());

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );

  GetIt.I.registerLazySingleton<BMMProvider>(
    () => BMMProvider(),
  );

  GetIt.I.registerLazySingleton<ZCashProvider>(
    () => ZCashProvider(),
  );

  GetIt.I.registerLazySingleton<CastProvider>(
    () => CastProvider(),
  );
}

// register all rpc connections. We attempt to create all
// rpcs in parallell, so they're ready instantly when swapping
// we can also query the balance
Future<SidechainRPC> findSubRPC(
  Sidechain chain,
  List<Binary> binaries, {
  KeyValueStore? store,
}) async {
  Logger log = GetIt.I.get<Logger>();
  final network = RuntimeArgs.network ?? SailNetworkValues.regtest.asString();

  final conf = await findSidechainConf(chain, network);

  SidechainRPC? sidechain;

  if (chain is TestSidechain) {
    log.i('starting init testchain RPC');

    final testchainBinary = binaries.firstWhere((b) => b is TestSidechain);
    final testchain = TestchainRPCLive(
      conf: conf,
      binary: testchainBinary,
      logPath: testchainBinary.logPath(),
      restartOnFailure: false,
    );
    sidechain = testchain;

    if (!GetIt.I.isRegistered<TestchainRPC>()) {
      GetIt.I.registerLazySingleton<TestchainRPC>(
        () => testchain,
      );
    }
  }

  if (chain is EthereumSidechain) {
    log.i('starting init ethereum RPC');

    final ethereumBinary = binaries.firstWhere((b) => b is EthereumSidechain);
    final ethChain = EthereumRPCLive(
      conf: conf,
      binary: ethereumBinary,
      logPath: ethereumBinary.logPath(),
      restartOnFailure: false,
    );
    sidechain = ethChain;

    if (!GetIt.I.isRegistered<EthereumRPC>()) {
      GetIt.I.registerLazySingleton<EthereumRPC>(
        () => ethChain,
      );
    }
  }

  if (chain == ZCash()) {
    log.i('starting init zcash RPC');
    if (store == null) {
      log.i('no store provided, taking from client settings');
      final settings = GetIt.I.get<ClientSettings>();
      store = settings.store;
    }

    final zChain = MockZCashRPCLive(
      storage: store,
    );
    sidechain = zChain;

    if (!GetIt.I.isRegistered<ZCashRPC>()) {
      GetIt.I.registerLazySingleton<ZCashRPC>(
        () => zChain,
      );
    }
  }

  if (chain == Thunder()) {
    log.i('starting init thunder RPC');

    final binary = binaries.firstWhere((b) => b is Thunder);
    final tChain = await ThunderLive.create(
      binary: binary,
      logPath: binary.logPath(),
      chain: chain,
    );
    sidechain = tChain;

    if (!GetIt.I.isRegistered<ThunderRPC>()) {
      GetIt.I.registerLazySingleton<ThunderRPC>(
        () => tChain,
      );
    }
  }

  if (chain == Bitnames()) {
    log.i('starting init bitnames RPC');

    final binary = binaries.firstWhere((b) => b is Bitnames);
    final bChain = await BitnamesLive.create(
      binary: binary,
      logPath: binary.logPath(),
      chain: chain,
    );
    sidechain = bChain;

    if (!GetIt.I.isRegistered<BitnamesRPC>()) {
      GetIt.I.registerLazySingleton<BitnamesRPC>(
        () => bChain,
      );
    }
  }

  return sidechain!;
}

Future<File> getLogFile() async {
  final datadir = await RuntimeArgs.datadir();
  try {
    await datadir.create(recursive: true);
  } catch (error) {
    debugPrint('Failed to create datadir: $error');
  }

  final path = [datadir.path, 'debug.log'].join(Platform.pathSeparator);
  final logFile = File(path);

  return logFile;
}

void bootBinaries(Logger log) async {
  final BinaryProvider binaryProvider = GetIt.I.get<BinaryProvider>();
  final SidechainContainer sidechain = GetIt.I.get<SidechainContainer>();

  await binaryProvider.downloadThenBootBinary(
    // boot whatever sidechain is active, eg zcash, thunder, testchain
    sidechain.rpc.binary,
  );
}

Future<List<Binary>> _loadBinaries(Directory appDir) async {
  // Register all binaries
  var binaries = [
    ParentChain(),
    Enforcer(),
    ZCash(),
    EthereumSidechain(),
    Thunder(),
    Bitnames(),
  ];

  return await loadBinaryMetadata(binaries, appDir);
}
