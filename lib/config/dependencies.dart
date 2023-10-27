import 'package:get_it/get_it.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/secure_store.dart';

// register all global dependencies, for use in views, or in view models
// each dependency can only be registered once
Future<void> initGetitDependencies() async {
  GetIt.I.registerLazySingleton<RPC>(
    () => RPC(),
  );

  GetIt.I.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(store: SecureStore()),
  );
}
