import 'package:drivechain_client/env.dart';
import 'package:drivechain_client/routing/router.dart';
import 'package:drivechain_client/service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() async {
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

  runApp(
    DrivechainService(
      child: SailApp(
        builder: (context) {
          return MaterialApp.router(
            routerDelegate: router.delegate(),
            routeInformationParser: router.defaultRouteParser(),
            title: "Drivechain",
            theme: ThemeData(
              textTheme: GoogleFonts.interTextTheme(),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color(0xffFF8000),
              ),
            ),
          );
        },
        initMethod: (_) => Future.value(),
        accentColor: const Color(0xff000000),
        log: log,
      ),
    ),
  );
}
