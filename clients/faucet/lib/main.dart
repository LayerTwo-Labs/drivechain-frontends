import 'package:faucet/api/api.dart';
import 'package:faucet/api/api_base.dart';
import 'package:faucet/providers/transactions_provider.dart';
import 'package:faucet/routing/router.dart';
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

  final router = GetIt.I.get<AppRouter>();

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (context) {
        return MaterialApp.router(
          routerDelegate: router.delegate(),
          routeInformationParser: router.defaultRouteParser(),
          title: 'Faucet',
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            fontFamily: 'Inter',
          ),
        );
      },
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
    () => APILive(),
  );

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );

  GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());
}
