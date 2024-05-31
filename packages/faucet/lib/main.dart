import 'package:faucet/api/api.dart';
import 'package:faucet/app.dart';
import 'package:faucet/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  start();
}

Future<void> start() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  await initDependencies();

  runApp(
    const MyApp(),
  );
}

Future<void> initDependencies() async {
  // api must be registered first, because other singletons depend on it
  GetIt.I.registerLazySingleton<API>(
    () => APILive(apiURL: 'https://api.drivechain.live'),
  );

  GetIt.I.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(),
  );
}
