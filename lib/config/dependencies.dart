import 'package:get_it/get_it.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/secure_store.dart';

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initGetitDependencies(Sidechain chain) async {
  final mainFuture = MainchainRPCLive.create();
  await setSidechainRPC(chain);
  final mainRPC = await mainFuture;

  GetIt.I.registerLazySingleton<MainchainRPC>(
    () => mainRPC,
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
  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );
}

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> setSidechainRPC(Sidechain chain) async {
  SidechainRPC sidechainRPC;
  switch (chain.type) {
    case SidechainType.testChain:
      final testchainRPC = await TestchainRPCLive.create();
      if (GetIt.I.isRegistered<TestchainRPC>()) {
        GetIt.I.unregister<TestchainRPC>();
      }
      GetIt.I.registerLazySingleton<TestchainRPC>(
        () => testchainRPC,
      );
      sidechainRPC = testchainRPC;
      break;

    case SidechainType.ethereum:
      final testchainRPC = await EthereumRPCLive.create();
      if (GetIt.I.isRegistered<EthereumRPC>()) {
        GetIt.I.unregister<EthereumRPC>();
      }
      GetIt.I.registerLazySingleton<EthereumRPC>(
        () => testchainRPC,
      );
      sidechainRPC = testchainRPC;
      break;
  }

  if (GetIt.I.isRegistered<SidechainRPC>()) {
    GetIt.I.unregister<SidechainRPC>();
  }
  GetIt.I.registerLazySingleton<SidechainRPC>(
    () => sidechainRPC,
  );

  SailApp.sailAppKey.currentState?.rebuildUI();
}
