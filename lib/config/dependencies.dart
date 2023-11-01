import 'package:get_it/get_it.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/secure_store.dart';

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initGetitDependencies() async {
  // TODO: this can throw an error. How do we display that to the user?
  final rpcConfig = await readRpcConfig();
  GetIt.I.registerLazySingleton<RPC>(
    () => RPCLive(rpcConfig),
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
