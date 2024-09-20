import 'dart:async';

import 'package:drivechain_client/api.dart';
import 'package:drivechain_client/env.dart';
import 'package:drivechain_client/providers/transactions_provider.dart';
import 'package:drivechain_client/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Environment.validateAtRuntime();

  final log = Logger();
  final router = AppRouter();
  final prefs = await SharedPreferences.getInstance();

  // Needed for sidesail_ui to work
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
      log: log,
    ),
  );

  GetIt.I.registerLazySingleton<API>(
    () => APILive(
      host: env(Environment.drivechainHost),
      port: env(Environment.drivechainPort),
    ),
  );

  final txProvider = TransactionProvider();
  GetIt.I.registerLazySingleton<TransactionProvider>(
    () => txProvider,
  );
  unawaited(txProvider.fetch());

  return runApp(
    SailApp(
      dense: true,
      builder: (context) {
        return MaterialApp.router(
          routerDelegate: router.delegate(),
          routeInformationParser: router.defaultRouteParser(),
          title: 'Drivechain',
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            fontFamily: 'Inter',
            textTheme: GoogleFonts.interTightTextTheme(
              GoogleFonts.sourceCodeProTextTheme(),
            ),
            scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
          ),
        );
      },
      accentColor: const Color.fromARGB(255, 255, 153, 0),
      log: log,
    ),
  );
}
