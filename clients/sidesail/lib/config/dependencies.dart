import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/providers/bmm_provider.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';
import 'package:sidesail/storage/sail_settings/network_settings.dart';

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initDependencies(Sidechain chain) async {
  final logFile = await getLogFile();
  final log = await logger(RuntimeArgs.fileLog, RuntimeArgs.consoleLog, logFile);
  GetIt.I.registerLazySingleton<Logger>(() => log);
  final prefs = await SharedPreferences.getInstance();
  final clientSettings = ClientSettings(
    store: Storage(
      preferences: prefs,
    ),
    log: log,
  );

  GetIt.I.registerLazySingleton<ClientSettings>(
    () => clientSettings,
  );
  GetIt.I.registerLazySingleton<ProcessProvider>(() => ProcessProvider());

  GetIt.I.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(),
  );

  final sidechain = await findSubRPC(chain);
  final sidechainContainer = await SidechainContainer.create(sidechain);
  GetIt.I.registerLazySingleton<SidechainContainer>(
    () => sidechainContainer,
  );

  final mainchainRPC = await MainchainRPCLive.create(
    ParentChain(),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );

  final binary = Enforcer();
  final enforcer = await EnforcerLive.create(
    binary: binary,
    logPath: path.join(binary.datadir(), 'bip300301_enforcer.log'),
  );
  GetIt.I.registerSingleton<EnforcerRPC>(enforcer);

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => BalanceProvider(
      connections: [enforcer],
    ),
  );

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
Future<SidechainRPC> findSubRPC(Sidechain chain) async {
  Logger log = GetIt.I.get<Logger>();
  final clientSettings = GetIt.I.get<ClientSettings>();
  final network = RuntimeArgs.network ?? (await clientSettings.getValue(NetworkSetting())).value.asString();

  final conf = await findSidechainConf(chain, network);

  SidechainRPC? sidechain;

  if (chain is TestSidechain) {
    log.i('starting init testchain RPC');

    final testchain = TestchainRPCLive(
      conf: conf,
      binary: TestSidechain(),
      logPath: TestSidechain().logDir(),
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

    final ethChain = EthereumRPCLive(
      conf: conf,
      binary: EthereumSidechain(),
      logPath: EthereumSidechain().logDir(),
    );
    sidechain = ethChain;

    if (!GetIt.I.isRegistered<EthereumRPC>()) {
      GetIt.I.registerLazySingleton<EthereumRPC>(
        () => ethChain,
      );
    }
  }

  if (chain == ZCashSidechain()) {
    log.i('starting init zcash RPC');

    final zChain = ZcashRPCLive(
      conf: conf,
      binary: ZCashSidechain(),
      logPath: ZCashSidechain().logDir(),
    );
    sidechain = zChain;

    if (!GetIt.I.isRegistered<ZCashRPC>()) {
      GetIt.I.registerLazySingleton<ZCashRPC>(
        () => zChain,
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
