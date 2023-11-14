import 'package:get_it/get_it.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/proc_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/secure_store.dart';

// This gets overwritten at a later point, just here to make the
// type system happy.
final _emptyNodeConf = SingleNodeConnectionSettings('', '', 0, '', '');

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initDependencies(Sidechain chain) async {
  await _initSidechainRPC(chain);

  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => MainchainRPCLive(conf: _emptyNodeConf),
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

  GetIt.I.registerLazySingleton(() => ProcessProvider());

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );
}

// register all rpc connections. We attempt to create all
// rpcs in parallell, so they're ready instantly when swapping
// we can also query the balance
Future<void> _initSidechainRPC(Sidechain chain) async {
  SidechainRPC Function() getSidechain;
  switch (chain.type) {
    case SidechainType.testChain:
      getSidechain = () => GetIt.I.get<TestchainRPC>();

    case SidechainType.ethereum:
      getSidechain = () => GetIt.I.get<EthereumRPC>();
  }
  GetIt.I.registerLazySingleton<TestchainRPC>(
    () => TestchainRPCLive(conf: _emptyNodeConf),
  );
  GetIt.I.registerLazySingleton<EthereumRPC>(
    () {
      final sc = EthereumSidechain();
      // TODO: make this properly configurable
      return EthereumRPCLive(
        conf: SingleNodeConnectionSettings(
          'todo.conf',
          'localhost',
          sc.rpcPort,
          '',
          '',
        ),
      );
    },
  );

  GetIt.I.registerLazySingleton<SidechainContainer>(
    () => SidechainContainer(getSidechain()),
  );
}
