import 'package:get_it/get_it.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/proc_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
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
final _emptyNodeConf = SingleNodeConnectionSettings('', '', 0, '', '');

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initDependencies(Sidechain chain) async {
  await _initSidechainRPC(chain);

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

  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(store: SecureStore()),
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
}

// register all rpc connections. We attempt to create all
// rpcs in parallell, so they're ready instantly when swapping
// we can also query the balance
Future<void> _initSidechainRPC(Sidechain chain) async {
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
  GetIt.I.registerLazySingleton<TestchainRPC>(
    () => testchain,
  );

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
  GetIt.I.registerLazySingleton<EthereumRPC>(
    () => ethChain,
  );

  final zChain = ZCashRPCLive(
    conf: ethConf,
  );
  GetIt.I.registerLazySingleton<ZCashRPC>(
    () => zChain,
  );

  SidechainRPC sidechain;
  switch (chain.type) {
    case SidechainType.testChain:
      sidechain = testchain;

    case SidechainType.ethereum:
      sidechain = ethChain;

    case SidechainType.zcash:
      sidechain = zChain;
  }

  final sidechainContainer = await SidechainContainer.create(sidechain);
  GetIt.I.registerLazySingleton<SidechainContainer>(
    () => sidechainContainer,
  );
}
