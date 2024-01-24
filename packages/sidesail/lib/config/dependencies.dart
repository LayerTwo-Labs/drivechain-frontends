import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/bmm_provider.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/process_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/secure_store.dart';

// This gets overwritten at a later point, just here to make the
// type system happy.
final _emptyNodeConf = SingleNodeConnectionSettings.empty();

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initDependencies(Sidechain chain) async {
  final log = await logger();
  GetIt.I.registerLazySingleton<Logger>(() => log);

  final sidechain = await findSubRPC(chain);
  final sidechainContainer = await SidechainContainer.create(sidechain);
  GetIt.I.registerLazySingleton<SidechainContainer>(
    () => sidechainContainer,
  );

  SingleNodeConnectionSettings mainchainConf = _emptyNodeConf;
  try {
    mainchainConf = await readRpcConfig(mainchainDatadir(), 'drivechain.conf', null);
  } catch (error) {
    // do nothing
  }
  final mainchainRPC = await MainchainRPCLive.create(mainchainConf);
  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainchainRPC,
  );

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  final prefs = await SharedPreferences.getInstance();
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
    ),
  );

  GetIt.I.registerLazySingleton<BalanceProvider>(
    // by registering an instance of the balance provider,
    // we start polling for balance updates
    () => BalanceProvider(),
  );

  GetIt.I.registerLazySingleton<ProcessProvider>(() => ProcessProvider());

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
  final log = await logger();

  SidechainRPC? sidechain;

  if (chain.type == SidechainType.testChain) {
    log.i('starting init testchain RPC');

    SingleNodeConnectionSettings testchainConf = _emptyNodeConf;
    try {
      testchainConf = await readRpcConfig(
        TestSidechain().type.datadir(),
        TestSidechain().type.confFile(),
        TestSidechain(),
      );
    } catch (error) {
      // do nothing, just don't exit
    }
    final testchain = TestchainRPCLive(conf: testchainConf);
    sidechain = testchain;

    if (!GetIt.I.isRegistered<TestchainRPC>()) {
      GetIt.I.registerLazySingleton<TestchainRPC>(
        () => testchain,
      );
    }
  }

  if (chain.type == SidechainType.ethereum) {
    log.i('starting init ethereum RPC');

    SingleNodeConnectionSettings ethConf = _emptyNodeConf;
    try {
      ethConf = await readRpcConfig(
        EthereumSidechain().type.datadir(),
        EthereumSidechain().type.confFile(),
        EthereumSidechain(),
      );
    } catch (error) {
      // do nothing, just don't exit
    }
    final ethChain = EthereumRPCLive(
      conf: ethConf,
    );
    sidechain = ethChain;

    if (!GetIt.I.isRegistered<EthereumRPC>()) {
      GetIt.I.registerLazySingleton<EthereumRPC>(
        () => ethChain,
      );
    }
  }

  if (chain.type == SidechainType.zcash) {
    log.i('starting init zcash RPC');

    SingleNodeConnectionSettings zcashConf = _emptyNodeConf;
    try {
      zcashConf = await readRpcConfig(
        '.',
        ZCashSidechain().type.confFile(),
        ZCashSidechain(),
      );
    } catch (error) {
      // do nothing, just don't exit
    }
    final zChain = ZcashRPCLive(
      conf: zcashConf,
    );
    sidechain = zChain;

    if (!GetIt.I.isRegistered<EthereumRPC>()) {
      GetIt.I.registerLazySingleton<ZCashRPC>(
        () => zChain,
      );
    }
  }

  return sidechain!;
}
