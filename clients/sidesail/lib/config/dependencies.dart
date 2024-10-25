import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/bmm_provider.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
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

  NodeConnectionSettings mainchainConf = NodeConnectionSettings.empty();
  try {
    final network = RuntimeArgs.network ?? (await clientSettings.getValue(NetworkSetting())).value.asString();
    mainchainConf = await readRPCConfig(ParentChain().type.datadir(), 'drivechain.conf', ParentChain(), network);
  } catch (error) {
    // do nothing
  }
  final mainchainRPC = await MainchainRPCLive.create(
    mainchainConf,
    ParentChain().binary,
    ParentChain().type.logDir(),
  );
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    // by registering an instance of the balance provider,
    // we start polling for balance updates
    () => BalanceProvider(),
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

  if (chain.type == ChainType.testchain) {
    log.i('starting init testchain RPC');

    final testchain = TestchainRPCLive(
      conf: conf,
      binary: TestSidechain().binary,
      logPath: TestSidechain().type.logDir(),
    );
    sidechain = testchain;

    if (!GetIt.I.isRegistered<TestchainRPC>()) {
      GetIt.I.registerLazySingleton<TestchainRPC>(
        () => testchain,
      );
    }
  }

  if (chain.type == ChainType.ethereum) {
    log.i('starting init ethereum RPC');

    final ethChain = EthereumRPCLive(
      conf: conf,
      binary: EthereumSidechain().binary,
      logPath: EthereumSidechain().type.logDir(),
    );
    sidechain = ethChain;

    if (!GetIt.I.isRegistered<EthereumRPC>()) {
      GetIt.I.registerLazySingleton<EthereumRPC>(
        () => ethChain,
      );
    }
  }

  if (chain.type == ChainType.zcash) {
    log.i('starting init zcash RPC');

    final zChain = ZcashRPCLive(
      conf: conf,
      binary: ZCashSidechain().binary,
      logPath: ZCashSidechain().type.logDir(),
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
