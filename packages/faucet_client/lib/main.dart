import 'package:faucet_client/api/api.dart';
import 'package:faucet_client/app.dart';
import 'package:faucet_client/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  start();
}

Future<void> start() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  await initDependencies();
  final log = GetIt.I.get<Logger>();

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (_) => MaterialApp(
        title: 'Drivechain Faucet',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const FaucetPage(title: 'Drivechain Faucet'),
      ),
      accentColor: SailColorScheme.orange,
      log: log,
    ),
  );
}

Future<void> initDependencies() async {
  final log = await logger(false, true, null);
  GetIt.I.registerLazySingleton<Logger>(() => log);
  final prefs = await SharedPreferences.getInstance();
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
      log: log,
    ),
  );

  // api must be registered first, because other singletons depend on it
  GetIt.I.registerLazySingleton<API>(
    () => APILive(apiURL: 'https://api.drivechain.live'),
  );

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );
}
